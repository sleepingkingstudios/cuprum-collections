# frozen_string_literal: true

require 'cuprum/collections/commands'
require 'cuprum/collections/commands/query_command'
require 'cuprum/collections/errors/invalid_query'

module Cuprum::Collections::Commands
  # Abstract implementation of the FindMatching command.
  module AbstractFindMatching
    include Cuprum::Collections::Commands::QueryCommand

    private

    def apply_query(limit:, offset:, order:, scope:)
      query = self.query
      query = query.limit(limit)   if limit
      query = query.offset(offset) if offset
      query = query.order(order)   if order
      query = query.where(scope)   if scope

      success(query)
    end

    def build_scope(value, &block)
      return Cuprum::Collections::Scope.build(&block) if block_given?

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
          limit:  limit,
          offset: offset,
          order:  order,
          scope:  scope
        )
      end

      envelope ? wrap_query(query) : query.each
    end

    def wrap_query(query)
      { collection_name => query.to_a }
    end
  end
end
