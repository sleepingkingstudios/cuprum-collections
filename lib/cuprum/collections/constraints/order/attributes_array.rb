# frozen_string_literal: true

require 'cuprum/collections/constraints/attribute_name'
require 'cuprum/collections/constraints/order'

require 'stannum/constraints/types/array_type'

module Cuprum::Collections::Constraints::Order
  # Asserts that the object is an Array of attribute names.
  class AttributesArray < Stannum::Constraints::Types::ArrayType
    # @return [Cuprum::Collections::Constraints::Order::AttributesArray] a
    #   cached instance of the constraint with default options.
    def self.instance
      @instance ||= new
    end

    # @return [Cuprum::Collections::Constraints::Order::AttributesArray] a
    #   cached instance of the constraint with allow_empty: false.
    def self.non_empty_instance
      @non_empty_instance ||= new(allow_empty: false)
    end

    # @param options [Hash<Symbol, Object>] Configuration options for the
    #   constraint. Defaults to an empty Hash.
    def initialize(**options)
      super(
        item_type: Cuprum::Collections::Constraints::AttributeName.instance,
        **options
      )
    end
  end
end
