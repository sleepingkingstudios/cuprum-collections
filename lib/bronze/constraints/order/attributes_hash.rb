# frozen_string_literal: true

require 'bronze/constraints/attribute_name'
require 'bronze/constraints/order'
require 'bronze/constraints/order/sort_direction'

module Bronze::Constraints::Order
  # Asserts that the object is a Hash of attribute names and sort directions.
  class AttributesHash < Stannum::Constraints::Types::HashType
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
        key_type:   Bronze::Constraints::AttributeName.instance,
        value_type: Bronze::Constraints::Order::SortDirection
          .instance,
        **
      )
    end
  end
end
