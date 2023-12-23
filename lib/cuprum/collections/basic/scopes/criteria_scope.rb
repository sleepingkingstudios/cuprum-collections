# frozen_string_literal: true

require 'cuprum/collections/basic/scope'
require 'cuprum/collections/basic/scopes'
require 'cuprum/collections/queries'
require 'cuprum/collections/scopes/criteria'

module Cuprum::Collections::Basic::Scopes
  # Scope for filtering on basic collection data based on criteria.
  class CriteriaScope < Cuprum::Collections::Basic::Scope
    include Cuprum::Collections::Scopes::Criteria

    Operators = Cuprum::Collections::Queries::Operators
    private_constant :Operators

    # Filters the provided data based on the configured criteria.
    def call(data:)
      raise ArgumentError, 'data must be an Array' unless data.is_a?(Array)

      criteria.reduce(data) do |filtered, (attribute, operator, value)|
        filtered.select(&filter_for(attribute, operator, value))
      end
    end

    private

    def filter_for(attribute, operator, value) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
      case operator
      when Operators::EQUAL
        @eq_filter ||= ->(item) { item[attribute] == value }
      when Operators::GREATER_THAN
        @gt_filter ||= ->(item) { item[attribute] > value }
      when Operators::GREATER_THAN_OR_EQUAL_TO
        @gte_filter ||= ->(item) { item[attribute] >= value }
      when Operators::LESS_THAN
        @lt_filter ||= ->(item) { item[attribute] < value }
      when Operators::LESS_THAN_OR_EQUAL_TO
        @lte_filter ||= ->(item) { item[attribute] <= value }
      when Operators::NOT_EQUAL
        @ne_filter ||= ->(item) { item[attribute] != value }
      when Operators::NOT_ONE_OF
        @nin_filter ||= ->(item) { !value.include?(item[attribute]) }
      when Operators::ONE_OF
        @in_filter ||= ->(item) { value.include?(item[attribute]) }
      else
        error_class =
          Cuprum::Collections::Scopes::Criteria::UnknownOperatorException
        message     = %(unknown operator "#{operator}")

        raise error_class.new(message, operator)
      end
    end
  end
end
