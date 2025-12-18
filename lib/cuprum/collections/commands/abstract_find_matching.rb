# frozen_string_literal: true

require 'cuprum/parameter_validation'

require 'cuprum/collections/commands'
require 'cuprum/collections/constraints/ordering'
require 'cuprum/collections/errors/invalid_query'

module Cuprum::Collections::Commands
  # Abstract implementation of the FindMatching command.
  module AbstractFindMatching
    include Cuprum::ParameterValidation

    # @!method call(envelope: false, limit: nil, offset: nil, order: nil, scope: nil, where: nil, &block)
    #   Queries the collection for items matching the given conditions.
    #
    #   @param envelope [Boolean] If true, wraps the result value in a Hash.
    #   @param limit [Integer] The maximum number of results to return.
    #   @param offset [Integer] The initial ordered items to skip.
    #   @param order [Array<String, Symbol>, Hash<{String, Symbol => Symbol}>]
    #     The sort order of the returned items. Should be either an array of
    #     attribute names or a hash of attribute names and directions.
    #   @param scope [Cuprum::Collections::Basic::Query, nil] Optional scope for
    #     the query. Items must match the scope as well as the :where filters.
    #   @param where [Object] Additional filters for selecting data. The command
    #     will only return data matching these filters.
    #   @yield The given block is passed to a QueryBuilder, which converts the
    #     block to query criteria and generates a new query using those
    #     criteria.
    #   @yieldreturn [Hash] The filters to apply to the query. The hash keys
    #     should be the names of attributes or columns, and the corresponding
    #     values should be either the literal value for that attribute or a
    #     method call for a valid operation defined for the query.
    #
    #   @example Querying all items in the collection.
    #     command = FindMatching.new(collection_name: 'books', data: books)
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
    #
    #   @example Wrapping the result in an envelope
    #     command =
    #       FindMatching.new(
    #         collection_name: 'books',
    #         data:            books
    #       )
    #     command.call(envelope: true)
    #     #=> {
    #       'books' => [] # an array containing the matching items
    #     }
    #
    #   @overload call(limit: nil, offset: nil, order: nil, &block)
    #     When the :envelope option is false (default), the command returns an
    #     Enumerator which can be iterated to return the matching items.
    #
    #     @return [Cuprum::Result<Enumerator>] the matching items in the
    #       specified order as an Enumerator.
    #
    #   @overload call(limit: nil, offset: nil, order: nil, &block)
    #     When the :envelope option is true, the command immediately evaluates
    #     the query and wraps the resulting array in a Hash, using the name of
    #     the collection as the key.
    #
    #     @return [Cuprum::Result<Hash{String, Array<Hash{String, Object}>}>] a
    #       hash with the collection name as key and the matching items as
    #       value.
    validate :envelope, :boolean, optional: true
    validate :limit,    Integer,  optional: true
    validate :offset,   Integer,  optional: true
    validate :order
    validate :where

    private

    def apply_query(limit:, offset:, order:, scope:)
      query = self.query
      query = query.limit(limit)   if limit
      query = query.offset(offset) if offset
      query = query.order(order)   if order
      query = query.where(scope)   if scope

      success(query)
    end

    def build_scope(value, &)
      return Cuprum::Collections::Scope.build(&) if block_given?

      return Cuprum::Collections::Scope.build(&value) if value.is_a?(Proc)

      return value if value.is_a?(Cuprum::Collections::Scopes::Base)

      Cuprum::Collections::Scope.build(value) if value
    rescue ArgumentError => exception
      error = Cuprum::Collections::Errors::InvalidQuery.new(
        message: exception.message,
        query:   value
      )

      failure(error)
    end

    def process(
      envelope: false,
      limit:    nil,
      offset:   nil,
      order:    nil,
      where:    nil,
      &block
    )
      scope = step { build_scope(where, &block) }
      query = step do
        apply_query(
          limit:,
          offset:,
          order:,
          scope:
        )
      end

      envelope ? wrap_query(query) : query.each
    end

    def validate_order(value, as: 'order')
      return if value.nil?

      match, errors =
        Cuprum::Collections::Constraints::Ordering.new.match(value)

      return if match

      "#{as} #{errors.summary}"
    end

    def validate_where(value, as: 'where')
      return if value.nil?

      return if value.is_a?(Proc) && (-1..1).cover?(value.arity)

      return if value.is_a?(Cuprum::Collections::Scopes::Base)

      return if validate_attributes(value, as:).empty?

      "#{as} is not a scope or query hash"
    end

    def wrap_query(query)
      { collection_name => query.to_a }
    end
  end
end
