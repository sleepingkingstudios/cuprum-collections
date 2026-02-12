# frozen_string_literal: true

require 'bronze/constraints/attribute_name'
require 'bronze/constraints/order'

require 'stannum/constraints/types/array_type'

module Bronze::Constraints::Order
  # Asserts that the object is an Array of attribute names.
  class AttributesArray < Stannum::Constraints::Types::ArrayType
    # @return [Bronze::Constraints::Order::AttributesArray] a cached instance of
    #   the constraint with default options.
    def self.instance
      @instance ||= new
    end

    # @overload initialize(**options)
    #   @param options [Hash<Symbol, Object>] Configuration options for the
    #     constraint. Defaults to an empty Hash.
    def initialize(**)
      super(
        item_type: Bronze::Constraints::AttributeName.instance,
        **
      )
    end
  end
end
