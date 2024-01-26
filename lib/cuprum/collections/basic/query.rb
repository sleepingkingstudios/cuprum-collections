# frozen_string_literal: true

require 'cuprum/collections/basic'
require 'cuprum/collections/basic/scopes/null_scope'
require 'cuprum/collections/query'

module Cuprum::Collections::Basic
  # Concrete implementation of a Query for an in-memory collection.
  class Query < Cuprum::Collections::Query
    # @param data [Array<Hash>] The current data in the collection. Should be an
    #   Array of Hashes, each of which represents one item in the collection.
    # @param scope [Cuprum::Collections::Scopes::Base] the base scope for the
    #   query. Defaults to nil.
    def initialize(data, scope: nil)
      super(scope: scope)

      @data = data
    end

    # Iterates through the collection, yielding each item matching the query.
    #
    # If the query has criteria, only items matching each criterion will be
    # processed; these are the matching items. If the query does not have any
    # criteria, all items in the collection will be processed.
    #
    # If the query has an ordering, the matching items are then sorted in the
    # specified order. If the query does not have an order, the matching items
    # will be processed in the order they appear in the collection.
    #
    # Finally, the limit and/or offset will be applied to the sorted matching
    # items. Each sorted, matching item starting at the offset and up to the
    # given limit of items will be yielded to the block.
    #
    # @overload each
    #   @return [Enumerator] an enumerator that iterates over the sorted,
    #     matching items within the given offset and limit.
    #
    # @overload each(&block)
    #   @yield [Object] Each sorted, matching item within the given offset and
    #     limit is yielded to the block.
    #
    # @see #limit
    # @see #offset
    # @see #order
    # @see #to_a
    # @see #where
    def each(...)
      return enum_for(:each, ...) unless block_given?

      scoped_data.each(...)
    end

    # Checks for the presence of collection items matching the query.
    #
    # If the query has criteria, then only items matching each criterion will be
    # processed; these are the matching items. If there is at least one matching
    # item, #exists will return true; otherwise, it will return false.
    #
    # @return [Boolean] true if any items match the query; otherwise false.
    def exists?
      return data.any? unless scope

      data.any? { |item| scope.match?(item: item) }
    end

    # Returns an array containing each collection item matching the query.
    #
    # If the query has criteria, only items matching each criterion will be
    # processed; these are the matching items. If the query does not have any
    # criteria, all items in the collection will be processed.
    #
    # If the query has an ordering, the matching items are then sorted in the
    # specified order. If the query does not have an order, the matching items
    # will be processed in the order they appear in the collection.
    #
    # Finally, the limit and/or offset will be applied to the sorted matching
    # items. Each sorted, matching item starting at the offset and up to the
    # given limit of items will be returned in the array.
    #
    # @return [Array] The sorted, matching items within the given offset and
    #   limit.
    #
    # @see #each
    # @see #limit
    # @see #offset
    # @see #order
    # @see #where
    def to_a
      scoped_data
    end

    protected

    def reset!
      @scoped_data = nil

      self
    end

    private

    attr_reader :data

    attr_reader :filters

    def apply_limit_offset(data)
      return data[@offset...(@offset + @limit)] || [] if @limit && @offset
      return data[0...@limit] if @limit

      return data[@offset..] || [] if @offset

      data
    end

    def apply_order(data)
      return data if @order.empty?

      data.sort do |u, v|
        @order.reduce(0) do |memo, (attribute, direction)|
          next memo unless memo.zero?

          attr_name = attribute.to_s

          cmp = u[attr_name] <=> v[attr_name]

          direction == :asc ? cmp : -cmp
        end
      end
    end

    def apply_scope(data)
      scope ? scope.call(data: data) : data
    end

    def default_scope
      Cuprum::Collections::Basic::Scopes::NullScope.new
    end

    def scoped_data
      @scoped_data ||=
        data
          .then { |ary| apply_scope(ary) }
          .then { |ary| apply_order(ary) }
          .then { |ary| apply_limit_offset(ary) }
          .map(&:dup)
    end
  end
end
