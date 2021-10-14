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

    # Enumerates the valid operators as a Set for performant lookup.
    VALID_OPERATORS = Set.new(Operators.values).freeze
  end
end
