# frozen_string_literal: true

require 'cuprum/collections'
require 'cuprum/collections/queries/block_parser'

module Cuprum::Collections
  # Internal class that handles parsing and applying criteria to a query.
  class QueryBuilder
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
    def call(&block)
      criteria = parse_criteria(&block)

      build_query(criteria)
    end

    private

    def build_query(criteria)
      base_query
        .dup
        .send(:with_criteria, criteria)
    end

    def parse_block_criteria(&block)
      Cuprum::Collections::Queries::BlockParser.new.call(&block)
    end

    def parse_criteria(&block)
      parse_block_criteria(&block)
    end
  end
end
