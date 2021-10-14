# frozen_string_literal: true

require 'cuprum/collections/basic'
require 'cuprum/collections/query_builder'

module Cuprum::Collections::Basic
  # Concrete implementation of QueryBuilder for a basic query.
  class QueryBuilder < Cuprum::Collections::QueryBuilder
    # @param base_query [Cuprum::Collections::Basic::Query] The original
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

    def equal(attribute, value)
      ->(actual) { actual[attribute.to_s] == value }
    end
    alias eq equal

    def greater_than(attribute, value)
      ->(actual) { actual[attribute.to_s] > value }
    end
    alias gt greater_than

    def greater_than_or_equal_to(attribute, value)
      ->(actual) { actual[attribute.to_s] >= value }
    end
    alias gte greater_than_or_equal_to

    def less_than(attribute, value)
      ->(actual) { actual[attribute.to_s] < value }
    end
    alias lt less_than

    def less_than_or_equal_to(attribute, value)
      ->(actual) { actual[attribute.to_s] <= value }
    end
    alias lte less_than_or_equal_to

    def not_equal(attribute, value)
      ->(actual) { actual[attribute.to_s] != value }
    end
    alias ne not_equal

    def not_one_of(attribute, value)
      ->(actual) { !value.include?(actual[attribute.to_s]) }
    end

    def one_of(attribute, value)
      ->(actual) { value.include?(actual[attribute.to_s]) }
    end
  end
end
