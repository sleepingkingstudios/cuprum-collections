# frozen_string_literal: true

require 'sleeping_king_studios/tools/toolbox/constant_map'

require 'cuprum/collections'

module Cuprum::Collections
  # Namespace for internal functionality for implementing collection queries.
  module Queries
    # Defines the supported operators for a Query.
    Operators = SleepingKingStudios::Tools::Toolbox::ConstantMap.new(
      EQUAL:                    :equal,
      GREATER_THAN:             :greater_than,
      GREATER_THAN_OR_EQUAL_TO: :greater_than_or_equal_to,
      LESS_THAN:                :less_than,
      LESS_THAN_OR_EQUAL_TO:    :less_than_or_equal_to,
      NOT_EQUAL:                :not_equal,
      NOT_ONE_OF:               :not_one_of,
      ONE_OF:                   :one_of
    ).freeze

    # Exception raised when trying to invert an operator with no inverse.
    class UninvertibleOperatorException < StandardError; end

    # Exception raised when an invalid operator is referenced.
    class UnknownOperatorException < StandardError
      # @param msg [String] the exception message.
      # @param name [String] the name of the invalid operator.
      def initialize(msg = nil, name = nil)
        super(msg)

        @name = name
      end

      # @return [String] the name of the invalid operator.
      def name
        @name || cause&.name
      end
    end

    # Defines the negated operator corresponding to each operator.
    INVERTIBLE_OPERATORS = {
      Operators::EQUAL                    => Operators::NOT_EQUAL,
      Operators::GREATER_THAN             => Operators::LESS_THAN_OR_EQUAL_TO,
      Operators::GREATER_THAN_OR_EQUAL_TO => Operators::LESS_THAN,
      Operators::LESS_THAN                => Operators::GREATER_THAN_OR_EQUAL_TO, # rubocop:disable Layout/LineLength
      Operators::LESS_THAN_OR_EQUAL_TO    => Operators::GREATER_THAN,
      Operators::NOT_EQUAL                => Operators::EQUAL,
      Operators::NOT_ONE_OF               => Operators::ONE_OF,
      Operators::ONE_OF                   => Operators::NOT_ONE_OF
    }.freeze

    # Enumerates the valid operators as a Set for performant lookup.
    VALID_OPERATORS = Set.new(Operators.values).freeze
  end
end
