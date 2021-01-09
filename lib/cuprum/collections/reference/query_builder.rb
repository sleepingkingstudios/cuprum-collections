# frozen_string_literal: true

require 'cuprum/collections/query_builder'
require 'cuprum/collections/reference'

module Cuprum::Collections::Reference
  # Concrete implementation of QueryBuilder for a reference query.
  class QueryBuilder < Cuprum::Collections::QueryBuilder
    # @param base_query [Cuprum::Collections::Reference::Query] The original
    #   query.
    def initialize(base_query)
      super

      @filters = base_query.send(:filters)
    end

    private

    attr_reader :filters

    def build_filters(criteria)
      criteria.map do |(attribute, operator, value)|
        send(operator, attribute, value)
      end
    end

    def build_query(criteria)
      super.send(:with_filters, build_filters(criteria))
    end

    def eq(attribute, value)
      ->(actual) { actual[attribute] == value }
    end

    def ne(attribute, value)
      ->(actual) { actual[attribute] != value }
    end
  end
end
