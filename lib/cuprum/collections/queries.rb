# frozen_string_literal: true

require 'sleeping_king_studios/tools/toolbox/constant_map'

require 'cuprum/collections'

module Cuprum::Collections
  # Namespace for internal functionality for implementing collection queries.
  module Queries
    # Defines the supported operators for a Query.
    Operators = SleepingKingStudios::Tools::Toolbox::ConstantMap.new(
      EQUAL:     :eq,
      NOT_EQUAL: :ne
    ).freeze

    # Enumerates the valid operators as a Set for performant lookup.
    VALID_OPERATORS = Set.new(Operators.values).freeze
  end
end
