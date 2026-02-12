# frozen_string_literal: true

require 'stannum/constraints/enum'

require 'bronze/constraints/order'

module Bronze::Constraints::Order
  # Asserts that the object is a valid direction for a sort.
  class SortDirection < Stannum::Constraints::Enum
    # The :type of the error generated for a matching object.
    NEGATED_TYPE = 'bronze.constraints.is_valid_sort_direction'

    # The :type of the error generated for a non-matching object.
    TYPE = 'bronze.constraints.is_not_valid_sort_direction'

    # @return [Bronze::Constraints::AttributeName] a cached instance of the
    #   constraint with default options.
    def self.instance
      @instance ||= new
    end

    def initialize(**)
      super(*sort_directions, **)
    end

    private

    def sort_directions
      %w[asc ascending desc descending] + %i[asc ascending desc descending]
    end
  end
end
