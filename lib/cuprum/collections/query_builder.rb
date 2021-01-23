# frozen_string_literal: true

require 'cuprum/collections'
require 'cuprum/collections/queries/parse'

module Cuprum::Collections
  # Internal class that handles parsing and applying criteria to a query.
  class QueryBuilder
    # Exception class to be raised when the query cannot be parsed.
    class ParseError < RuntimeError; end

    # @param base_query [Cuprum::Collections::Query] The original query.
    def initialize(base_query)
      @base_query = base_query
    end

    # @return [Cuprum::Collections::Query] the original query.
    attr_reader :base_query

    # Returns a copy of the query updated with the generated criteria.
    #
    # Classifies the parameters to determine parsing strategy, then uses that
    # strategy to parse the parameters into an array of criteria. Then, copies
    # the original query and updates the copy with the parsed criteria.
    #
    # @return [Cuprum::Collections::Query] the copied and updated query.
    def call(*arguments, strategy: nil, **keywords, &block)
      criteria = parse_criteria(
        arguments: arguments,
        block:     block,
        keywords:  keywords,
        strategy:  strategy
      )

      build_query(criteria)
    end

    private

    def build_query(criteria)
      base_query
        .dup
        .send(:with_criteria, criteria)
    end

    def parse_criteria(strategy:, **parameters)
      result = Cuprum::Collections::Queries::Parse
        .new
        .call(strategy: strategy, **parameters)

      return result.value if result.success?

      raise ParseError, result.error.message
    end
  end
end
