# frozen_string_literal: true

require 'cuprum/collections/basic'
require 'cuprum/collections/basic/query_builder'
require 'cuprum/collections/query'

module Cuprum::Collections::Basic
  # Concrete implementation of a Query for an in-memory collection.
  class Query < Cuprum::Collections::Query
    include Enumerable

    # @param data [Array<Hash>] The current data in the collection. Should be an
    #   Array of Hashes, each of which represents one item in the collection.
    def initialize(data)
      super()

      @data    = data
      @filters = []
      @limit   = nil
      @offset  = nil
      @order   = {}
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
    def each(&block)
      return enum_for(:each) unless block_given?

      filtered_data.each(&block)
    end

    # Checks for the presence of collection items matching the query.
    #
    # If the query has criteria, then only items matching each criterion will be
    # processed; these are the matching items. If there is at least one matching
    # item, #exists will return true; otherwise, it will return false.
    #
    # @return [Boolean] true if any items match the query; otherwise false.
    def exists?
      data.any? do |item|
        @filters.all? { |filter| filter.call(item) }
      end
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
      filtered_data
    end

    protected

    def query_builder
      Cuprum::Collections::Basic::QueryBuilder.new(self)
    end

    def reset!
      @filtered_data = nil

      self
    end

    def with_filters(filters)
      @filters += filters

      self
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

    private

    attr_reader :data

    attr_reader :filters

    def apply_filters(data)
      data.select do |item|
        @filters.all? { |filter| filter.call(item) }
      end
    end

    def apply_limit_offset(data)
      return data[@offset...(@offset + @limit)] || [] if @limit && @offset
      return data[0...@limit] if @limit

      return data[@offset..-1] || [] if @offset

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

    def filtered_data
      @filtered_data ||=
        data
          .yield_self { |ary| apply_filters(ary) }
          .yield_self { |ary| apply_order(ary) }
          .yield_self { |ary| apply_limit_offset(ary) }
          .map(&:dup)
    end
  end
end
