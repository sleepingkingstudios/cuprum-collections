# frozen_string_literal: true

require 'cuprum/collections/basic/command'
require 'cuprum/collections/basic/commands'
require 'cuprum/collections/basic/query'
require 'cuprum/collections/commands/abstract_filter'
require 'cuprum/collections/constraints/ordering'

module Cuprum::Collections::Basic::Commands
  # Command for querying filtered, ordered data from a basic collection.
  class Filter < Cuprum::Collections::Basic::Command
    include Cuprum::Collections::Commands::AbstractFilter

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
    #   @example Querying all items in the collection.
    #     command = Filter.new(collection_name: 'books', data: books)
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
    #       Filter.new(collection_name: 'books', data: books, envelope: true)
    #     command.call
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

    # @param collection_name [String, Symbol] The name of the collection.
    # @param data [Array<Hash>] The current data in the collection.
    # @param envelope [Boolean] If true, wraps the result in a Hash and
    # @param options [Hash<Symbol>] Additional options for the command.
    def initialize(collection_name:, data:, envelope: false, **options)
      super(
        collection_name: collection_name,
        data:            data,
        envelope:        envelope,
        **options,
      )
    end

    validate_parameters :call do
      keyword :limit,  Integer, optional: true
      keyword :offset, Integer, optional: true
      keyword :order,
        Cuprum::Collections::Constraints::Ordering.new,
        optional: true
    end

    private

    def build_query
      Cuprum::Collections::Basic::Query.new(data)
    end
  end
end
