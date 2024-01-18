# frozen_string_literal: true

require 'cuprum/collections/basic/scopes'
require 'cuprum/collections/basic/scopes/base'
require 'cuprum/collections/queries'
require 'cuprum/collections/scopes/criteria'

module Cuprum::Collections::Basic::Scopes
  # Scope for filtering on basic collection data based on criteria.
  class CriteriaScope < Cuprum::Collections::Basic::Scopes::Base
    include Cuprum::Collections::Scopes::Criteria

    Operators = Cuprum::Collections::Queries::Operators
    private_constant :Operators

    # Returns true if the provided item matches the configured criteria.
    def match?(item:)
      super

      criteria.all? do |(attribute, operator, value)|
        filter_for(operator).call(item, attribute, value)
      end
    end
    alias matches? match?

    private

    def filter_for(operator) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
      case operator
      when Operators::EQUAL
        @eq_filter ||= ->(item, attribute, value) { item[attribute] == value }
      when Operators::GREATER_THAN
        @gt_filter ||= ->(item, attribute, value) { item[attribute] > value }
      when Operators::GREATER_THAN_OR_EQUAL_TO
        @gte_filter ||= ->(item, attribute, value) { item[attribute] >= value }
      when Operators::LESS_THAN
        @lt_filter ||= ->(item, attribute, value) { item[attribute] < value }
      when Operators::LESS_THAN_OR_EQUAL_TO
        @lte_filter ||= ->(item, attribute, value) { item[attribute] <= value }
      when Operators::NOT_EQUAL
        @ne_filter ||= ->(item, attribute, value) { item[attribute] != value }
      when Operators::NOT_ONE_OF
        @nin_filter ||=
          ->(item, attribute, value) { !value.include?(item[attribute]) }
      when Operators::ONE_OF
        @in_filter ||=
          ->(item, attribute, value) { value.include?(item[attribute]) }
      else
        error_class =
          Cuprum::Collections::Scopes::Criteria::UnknownOperatorException
        message     = %(unknown operator "#{operator}")

        raise error_class.new(message, operator)
      end
    end
  end
end
