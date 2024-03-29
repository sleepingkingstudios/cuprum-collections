# frozen_string_literal: true

require 'cuprum/collections'
require 'cuprum/collections/queries/ordering'
require 'cuprum/collections/scopes/all_scope'

module Cuprum::Collections
  # Abstract base class for collection Query implementations.
  class Query
    include Enumerable

    UNDEFINED = Object.new.freeze
    private_constant :UNDEFINED

    # @param scope [Cuprum::Collections::Scopes::Base] the base scope for the
    #   query. Defaults to nil.
    def initialize(scope: nil)
      @limit  = nil
      @offset = nil
      @order  = {}
      @scope  = scope ? default_scope.and(scope) : default_scope
    end

    # Returns the current scope for the query.
    #
    # Composition methods should not be called on the scope directly, as they
    # will not change the scope object bound to the query. Call the
    # corresponding methods on the query itself, i.e. call query.where() instead
    # of query.scope.where().
    #
    # @return [Cuprum::Collections::Scopes::Base] the current scope for the
    #   query.
    def scope
      @scope ||= default_scope
    end

    # Sets or returns the maximum number of items returned by the query.
    #
    # @overload limit
    #   @return [Integer, nil] the current limit for the query.
    #
    # @overload limit(count)
    #   Returns a copy of the query with the specified limit.
    #
    #   The query will return at most the specified number of items.
    #
    #   When #limit is called on a query that already defines a limit, the old
    #   limit is replaced with the new.
    #
    #   @param count [Integer] the maximum number of items to return.
    #
    #   @return [Query] the copy of the query.
    def limit(count = UNDEFINED)
      return @limit if count == UNDEFINED

      validate_limit(count)

      dup.tap { |copy| copy.with_limit(count) }
    end

    # Sets or returns the number of ordered items skipped by the query.
    #
    # @overload offset
    #   @return [Integer, nil] the current offset for the query.
    #
    # @overload offset(count)
    #   Returns a copy of the query with the specified offset.
    #
    #   The query will skip the specified number of matching items, and return
    #   only matching items after the given offset. If the total number of
    #   matching items is less than or equal to the offset, the query will not
    #   return any items.
    #
    #   When #offset is called on a query that already defines an offset, the
    #   old offset is replaced with the new.
    #
    #   @param count [Integer] the number of items to skip.
    #
    #   @return [Query] the copy of the query.
    def offset(count = UNDEFINED)
      return @offset if count == UNDEFINED

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
    # @overload order
    #   @return [Hash{String,Symbol=>Symbol}] the current ordering for the
    #     query.
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
    def order(*attributes)
      return @order if attributes.empty?

      normalized = Cuprum::Collections::Queries::Ordering.normalize(*attributes)

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

    # @overload where(hash)
    #   Returns a copy of the query with the specified filters.
    #
    #   If the query already has a scope, then the filters will be merged with
    #   the existing scope. Any items in the collection must match both the
    #   previous scope and the new criteria to be returned by the query.
    #
    #   @param hash [Hash{String=>Object}] the filters to apply to the query.
    #
    #   @example Filtering Data By Equality
    #     # The query will only return items whose author is 'J.R.R. Tolkien'.
    #     query = query.where { { author: 'J.R.R. Tolkien' } }
    #
    #   @see #scope
    #
    # @overload where(&block)
    #   Returns a copy of the query with the specified filters.
    #
    #   If the query already has a scope, then the filters will be merged with
    #   the existing scope. Any items in the collection must match both the
    #   previous scope and the new criteria to be returned by the query.
    #
    #   @yieldreturn [Hash{String=>Object}] the filters to apply to the query.
    #     The hash keys should be the names of attributes or columns, and the
    #     corresponding values should be either the literal value for that
    #     attribute or a method call for a valid operation defined for the
    #     query.
    def where(...)
      dup.with_scope(scope.where(...)).reset!
    end

    protected

    def reset!
      # :nocov:
      self
      # :nocov:
    end

    def with_limit(count)
      @limit = count

      self
    end

    def with_offset(count)
      @offset = count

      self
    end

    def with_order(order)
      @order = order

      self
    end

    def with_scope(scope)
      @scope = scope

      self
    end

    private

    def default_scope
      Cuprum::Collections::Scopes::AllScope.new
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
  end
end
