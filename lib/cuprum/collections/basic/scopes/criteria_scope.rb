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

    FILTERS = {
      Operators::EQUAL                    => lambda { |item, attribute, value|
        item[attribute] == value
      },
      Operators::GREATER_THAN             => lambda { |item, attribute, value|
        item[attribute] > value
      },
      Operators::GREATER_THAN_OR_EQUAL_TO => lambda { |item, attribute, value|
        item[attribute] >= value
      },
      Operators::LESS_THAN                => lambda { |item, attribute, value|
        item[attribute] < value
      },
      Operators::LESS_THAN_OR_EQUAL_TO    => lambda { |item, attribute, value|
        item[attribute] <= value
      },
      Operators::NOT_EQUAL                => lambda { |item, attribute, value|
        item[attribute] != value
      },
      Operators::NOT_NULL                 => lambda { |item, attribute, _value|
        !item[attribute].nil?
      },
      Operators::NOT_ONE_OF               => lambda { |item, attribute, value|
        !value.include?(item[attribute])
      },
      Operators::NULL                     => lambda { |item, attribute, _value|
        item[attribute].nil?
      },
      Operators::ONE_OF                   => lambda { |item, attribute, value|
        value.include?(item[attribute])
      }
    }.freeze
    private_constant :FILTERS

    # Returns true if the provided item matches the configured criteria.
    def match?(item:)
      super

      if inverted?
        criteria.any? do |(attribute, operator, value)|
          filter_for(operator).call(item, attribute, value)
        end
      else
        criteria.all? do |(attribute, operator, value)|
          filter_for(operator).call(item, attribute, value)
        end
      end
    end
    alias matches? match?

    private

    def filter_for(operator)
      FILTERS.fetch(operator) do
        error_class = Cuprum::Collections::Queries::UnknownOperatorException
        message     = %(unknown operator "#{operator}")

        raise error_class.new(message, operator)
      end
    end
  end
end
