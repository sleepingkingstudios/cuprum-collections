# frozen_string_literal: true

require 'cuprum/collections'

module Cuprum::Collections
  # Abstract base class for collection Query implementations.
  class Query
    # Exception class for handling invalid order keywords.
    class InvalidOrderError < ArgumentError; end

    ORDER_HASH_VALUES = {
      asc:        :asc,
      ascending:  :asc,
      desc:       :desc,
      descending: :desc
    }.freeze
    private_constant :ORDER_HASH_VALUES

    def initialize
      @criteria = []
    end

    # Returns a normalized representation of the query criteria.
    #
    # The query criteria define which data from the collection matches the
    # query. Specifically, an item in the collection matches the query if and
    # only if it matches each criterion. If the query has no criteria, then it
    # will match all items in the collection.
    #
    # Each criterion is represented as an Array with three elements:
    # - The name of the property or column to select by.
    # - The operation to filter, such as :eq (an equality operation).
    # - The expected value.
    #
    # For example, a query that selects all items whose :series property is
    # equal to 'The Lord of the Rings' would have the following criterion:
    # `[:series, :eq, 'The Lord of the Rings']`.
    #
    # @return [Array<Array>] the query criteria.
    #
    # @see #where
    def criteria
      @criteria.dup
    end

    # Returns a copy of the query with the specified limit.
    #
    # The query will return at most the specified number of items.
    #
    # When #limit is called on a query that already defines a limit, the old
    # limit is replaced with the new.
    #
    # @param count [Integer] the maximum number of items to return.
    #
    # @return [Query] the copy of the query.
    def limit(count)
      validate_limit(count)

      dup.tap { |copy| copy.with_limit(count) }
    end

    # Returns a copy of the query with the specified offset.
    #
    # The query will skip the specified number of matching items, and return
    # only matching items after the given offset. If the total number of
    # matching items is less than or equal to the offset, the query will not
    # return any items.
    #
    # When #offset is called on a query that already defines an offset, the old
    # offset is replaced with the new.
    #
    # @param count [Integer] the number of items to skip.
    #
    # @return [Query] the copy of the query.
    def offset(count)
      validate_offset(count)

      dup.tap { |copy| copy.with_offset(count) }
    end

    # Returns a copy of the query with the specified order.
    #
    # The query will find the matching items, sort them in the specified order,
    # and then apply limit and/or offset (if applicable) to determine the final
    # returned items.
    #
    # When #order is called on a query that already defines an ordering, the old
    # ordering is replaced with the new.
    #
    # @return [Query] the copy of the query.
    #
    # @example Sorting By Attribute Names
    #   # This query will sort books by author (ascending), then by title
    #   # (ascending) within authors.
    #   query = query.order(:author, :title)
    #
    # @example Sorting With Directions
    #   # This query will sort books by series (ascending), then by the date of
    #   # publication (descending) within series.
    #   query = query.order({ series: :asc, published_at: :desc })
    #
    # @overload order(*attributes)
    #   Orders the results by the given attributes, ascending, and in the
    #   specified order, i.e. items with the same value of the first attribute
    #   will be sorted by the second (if any), and so on.
    #
    #   @param attributes [Array<String, Symbol>] The attributes to order by.
    #
    # @overload order(attributes)
    #   Orders the results by the given attributes and sort directions, and in
    #   the specified order.
    #
    #   @param attributes [Hash{String,Symbol=>Symbol}] The attributes to order
    #     by. The hash keys should be the names of attributes or columns, and
    #     the corresponding values should be the sort direction for that
    #     attribute, either :asc or :desc.
    def order(first, *rest)
      normalized = normalize_order(first, *rest)

      dup.tap { |copy| copy.with_order(normalized) }
    end
    alias order_by order

    # Returns a copy of the query with no cached query results.
    #
    # Once the query has been called (e.g. by calling #each or #to_a), the
    # matching data is cached. If the underlying collection changes, those
    # changes will not be reflected in the query.
    #
    # Calling #reset clears the cached results. The next time the query is
    # called, the results will be drawn from the current collection state.
    #
    # @return [Cuprum::Collections::Query] a copy of the query with a cleared
    #   results cache.
    def reset
      dup.reset!
    end

    # Returns a copy of the query with the specified filters.
    #
    # The given parameters are used to construct query criteria, which define
    # which data from the collection matches the query. Specifically, an item in
    # the collection matches the query if and only if it matches each criterion.
    # If the query has no criteria, then it will match all items in the
    # collection.
    #
    # When #where is called on a query that already defines criteria, then the
    # new criteria are appended to the old. Any items in the collection must
    # match both the old and the new criteria to be returned by the query.
    #
    # @example Filtering Data By Equality
    #   # The query will only return items whose author is 'J.R.R. Tolkien'.
    #   query = query.where { { author: 'J.R.R. Tolkien' } }
    #
    # @example Filtering Data By Operator
    #   # The query will only return items whose author is 'J.R.R. Tolkien',
    #   # and whose series is not 'The Lord of the Rings'.
    #   query = query.where do
    #     {
    #       author: eq('J.R.R. Tolkien'),
    #       series: ne('The Lord of the Rings')
    #     }
    #   end
    #
    # @overload where(&block)
    #   @yield The given block is passed to a QueryBuilder, which converts the
    #     block to query criteria and generates a new query using those
    #     criteria.
    #
    #   @yieldreturn [Hash] The filters to apply to the query. The hash keys
    #     should be the names of attributes or columns, and the corresponding
    #     values should be either the literal value for that attribute or a
    #     method call for a valid operation defined for the query.
    #
    # @see #criteria
    def where(filter = nil, strategy: nil, &block)
      filter ||= block

      return dup if filter.nil? && strategy.nil?

      query_builder.call(strategy: strategy, where: filter)
    end

    protected

    def reset!
      # :nocov:
      self
      # :nocov:
    end

    def with_criteria(criteria)
      @criteria += criteria

      self
    end

    private

    def invalid_order_error
      'order must be a list of attribute names and/or a hash of attribute' \
      ' names with values :asc or :desc'
    end

    def normalize_order(*attributes)
      qualified = attributes.last.is_a?(Hash) ? attributes.pop : {}
      qualified = normalize_order_hash(qualified)

      validate_order_attributes(attributes)

      attributes
        .each
        .with_object({}) { |attribute, hsh| hsh[attribute.intern] = :asc }
        .merge(qualified)
        .tap { |hsh| validate_order_normalized(hsh) }
    end

    def normalize_order_hash(hsh)
      hsh.each.with_object({}) do |(key, value), normalized|
        unless valid_order_hash_key?(key)
          raise InvalidOrderError, invalid_order_error, caller(2..-1)
        end

        normalized[key.intern] = normalize_order_hash_value(value)
      end
    end

    def normalize_order_hash_value(value)
      value = value.downcase if value.is_a?(String)

      ORDER_HASH_VALUES.fetch(value.is_a?(String) ? value.intern : value) do
        raise InvalidOrderError, invalid_order_error, caller(3..-1)
      end
    end

    def valid_order_hash_key?(key)
      (key.is_a?(String) || key.is_a?(Symbol)) && !key.to_s.empty?
    end

    def validate_limit(count)
      return if count.is_a?(Integer) && !count.negative?

      raise ArgumentError, 'limit must be a non-negative integer', caller(1..-1)
    end

    def validate_offset(count)
      return if count.is_a?(Integer) && !count.negative?

      raise ArgumentError,
        'offset must be a non-negative integer',
        caller(1..-1)
    end

    def validate_order_attributes(attributes)
      return if attributes.all? do |item|
        (item.is_a?(String) || item.is_a?(Symbol)) && !item.to_s.empty?
      end

      raise InvalidOrderError, invalid_order_error, caller(2..-1)
    end

    def validate_order_normalized(hsh)
      raise InvalidOrderError, invalid_order_error, caller(2..-1) if hsh.empty?
    end
  end
end
