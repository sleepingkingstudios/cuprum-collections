# frozen_string_literal: true

require 'bronze/constraints'

module Bronze::Constraints
  # Namespace for constraints that validate query ordering.
  module Order
    autoload :AttributesArray, 'bronze/constraints/order/attributes_array'
    autoload :AttributesHash,  'bronze/constraints/order/attributes_hash'
    autoload :ComplexOrdering, 'bronze/constraints/order/complex_ordering'
    autoload :SortDirection,   'bronze/constraints/order/sort_direction'
  end
end
