# frozen_string_literal: true

require 'cuprum/collections/commands'
require 'cuprum/collections/queries/parse'

module Cuprum::Collections::Commands
  # Abstract implementation of the FindMatching command.
  #
  # Subclasses must define the #build_query method, which returns an empty
  # Query instance for that collection.
  module AbstractFindMatching
    private

    def apply_query(criteria:, limit:, offset:, order:)
      query = build_query
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
      envelope: false,
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
        apply_query(
          criteria: criteria,
          limit:    limit,
          offset:   offset,
          order:    order
        )
      end

      envelope ? wrap_query(query) : query.each
    end

    def wrap_query(query)
      { collection_name => query.to_a }
    end
  end
end
