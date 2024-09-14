# frozen_string_literal: true

require 'cuprum/collections/commands'
require 'cuprum/collections/constraints/ordering'
require 'cuprum/collections/errors/invalid_query'

module Cuprum::Collections::Commands
  # Abstract implementation of the FindMatching command.
  module AbstractFindMatching
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

      return if value.is_a?(Cuprum::Collections::Scopes::Base)

      return if validate_attributes(value, as:).empty?

      "#{as} is not a scope or query hash"
    end

    def wrap_query(query)
      { collection_name => query.to_a }
    end
  end
end
