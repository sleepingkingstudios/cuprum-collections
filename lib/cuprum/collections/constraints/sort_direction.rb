# frozen_string_literal: true

require 'stannum/constraints/enum'

require 'cuprum/collections/constraints'

module Cuprum::Collections::Constraints
  # Asserts that the object is a valid direction for a sort.
  class SortDirection < Stannum::Constraints::Enum
    # The :type of the error generated for a matching object.
    NEGATED_TYPE = 'cuprum.collections.constraints.is_valid_sort_direction'

    # The :type of the error generated for a non-matching object.
    TYPE = 'cuprum.collections.constraints.is_not_valid_sort_direction'

    def initialize(**options)
      super(*sort_directions, **options)
    end

    private

    def sort_directions
      %w[asc ascending desc descending] + %i[asc ascending desc descending]
    end
  end
end
