# frozen_string_literal: true

require 'cuprum/collections/constraints/attribute_name'
require 'cuprum/collections/constraints/order'
require 'cuprum/collections/constraints/order/sort_direction'

module Cuprum::Collections::Constraints::Order
  # Asserts that the object is a Hash of attribute names and sort directions.
  class AttributesHash < Stannum::Constraints::Types::HashType
    # @return [Cuprum::Collections::Constraints::Order::AttributesArray] a
    #   cached instance of the constraint with default options.
    def self.instance
      @instance ||= new
    end

    # @param options [Hash<Symbol, Object>] Configuration options for the
    #   constraint. Defaults to an empty Hash.
    def initialize(**options)
      super(
        key_type:   Cuprum::Collections::Constraints::AttributeName.instance,
        value_type: Cuprum::Collections::Constraints::Order::SortDirection
          .instance,
        **options
      )
    end
  end
end
