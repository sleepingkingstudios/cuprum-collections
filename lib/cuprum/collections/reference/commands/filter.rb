# frozen_string_literal: true

require 'cuprum/collections/constraints/ordering'
require 'cuprum/collections/queries/parse'
require 'cuprum/collections/reference/command'
require 'cuprum/collections/reference/commands'
require 'cuprum/collections/reference/query'

module Cuprum::Collections::Reference::Commands
  # Command for querying filtered, ordered data from a reference collection.
  class Filter < Cuprum::Collections::Reference::Command
    # @!method call(limit: nil, offset: nil, order: nil, &block)
    #   Queries the collection for items matching the given conditions.
    #
    #   @param limit [Integer] The maximum number of results to return.
    #   @param offset [Integer] The initial ordered items to skip.
    #   @param order [Array<String, Symbol>, Hash<{String, Symbol => Symbol}>]
    #     The sort order of the returned items. Should be either an array of
    #     attribute names or a hash of attribute names and directions.
    #   @yield The given block is passed to a QueryBuilder, which converts the
    #     block to query criteria and generates a new query using those
    #     criteria.
    #   @yieldreturn [Hash] The filters to apply to the query. The hash keys
    #     should be the names of attributes or columns, and the corresponding
    #     values should be either the literal value for that attribute or a
    #     method call for a valid operation defined for the query.
    #
    #   @return [Cuprum::Result<Enumerator>] the matching items in the specified
    #     order.
    #
    #   @example Querying all items in the collection.
    #     command.call
    #     #=> an enumerable iterating all items in the collection
    #
    #   @example Querying all items matching some critera:
    #     command.call { { author: 'Nnedi Okorafor' } }
    #     #=> an enumerable iterating all items in the collection whose author
    #         is 'Nnedi Okorafor'
    #
    #   @example Ordering query results
    #     command.call(order: :title) { { author: 'Nnedi Okorafor' } }
    #     #=> an enumerable iterating all items in the collection whose author
    #     #   is 'Nnedi Okorafor', sorted by :title in ascending order
    #
    #   @example Advanced filtering
    #     command.call do
    #       {
    #         category: eq('Science Fiction and Fantasy'),
    #         author:   ne('J.R.R. Tolkien')
    #       }
    #     end
    #     #=> an enumerable iterating all items in the collection whose category
    #     #   is 'Science Fiction and Fantasy', and whose author is not
    #     #   'J.R.R. Tolkien'.
    #
    #   @example Advanced ordering
    #     order = { author: :asc, genre: :desc }
    #     command.call(order: order) { { author: 'Nnedi Okorafor' } }
    #     #=> an enumerable iterating all items in the collection whose author
    #     #   is 'Nnedi Okorafor', sorted first by :author in ascending order
    #     #   and within the same author by genre in descending order
    #
    #   @example Filtering, ordering, and subsets
    #     command.call(offset: 50, limit: 10, order: :author) do
    #       { category: 'Science Fiction and Fantasy' }
    #     end
    #     #=> an enumerable iterating the 51st through 60th items in the
    #     #   collection whose category is 'Science Fiction and Fantasy', sorted
    #     #   by :author in ascending order.

    keyword :limit,  Integer, optional: true
    keyword :offset, Integer, optional: true
    keyword :order,
      Cuprum::Collections::Constraints::Ordering.new,
      optional: true

    private

    def build_query(criteria:, limit:, offset:, order:)
      query = Cuprum::Collections::Reference::Query.new(data)
      query = query.limit(limit)   if limit
      query = query.offset(offset) if offset
      query = query.order(order)   if order
      query = query.where(criteria, strategy: :unsafe) unless criteria.empty?

      success(query)
    end

    def parse_criteria(strategy:, where:, &block)
      return [] if strategy.nil? && where.nil? && !block_given?

      Cuprum::Collections::Queries::Parse.new.call(
        strategy: strategy,
        where:    where || block
      )
    end

    def process( # rubocop:disable Metrics/MethodLength, Metrics/ParameterLists
      limit:    nil,
      offset:   nil,
      order:    nil,
      strategy: nil,
      where:    nil,
      &block
    )
      criteria = step do
        parse_criteria(strategy: strategy, where: where, &block)
      end

      query = step do
        build_query(
          criteria: criteria,
          limit:    limit,
          offset:   offset,
          order:    order
        )
      end

      success(query.each)
    end
  end
end
