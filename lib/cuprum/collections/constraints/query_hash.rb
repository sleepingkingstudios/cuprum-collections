# frozen_string_literal: true

require 'stannum/constraints/types/hash_type'

require 'cuprum/collections/constraints'
require 'cuprum/collections/constraints/attribute_name'

module Cuprum::Collections::Constraints
  # Asserts that the object is a Hash with valid attribute name keys.
  class QueryHash < Stannum::Constraints::Types::HashType
    def initialize(**options)
      super(
        allow_empty: true,
        key_type:    attribute_name_constraint,
        **options
      )
    end

    private

    def attribute_name_constraint
      Cuprum::Collections::Constraints::AttributeName.instance
    end
  end
end
