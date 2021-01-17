# frozen_string_literal: true

require 'stannum/constraints/types/array'
require 'stannum/constraints/types/hash'
require 'stannum/constraints/union'
require 'stannum/support/optional'

require 'cuprum/collections/constraints'
require 'cuprum/collections/constraints/attribute_name'
require 'cuprum/collections/constraints/sort_direction'

module Cuprum::Collections::Constraints
  # @todo Document Ordering.
  class Ordering < Stannum::Constraints::Union
    include Stannum::Support::Optional

    # The :type of the error generated for a matching object.
    NEGATED_TYPE = 'cuprum.collections.constraints.is_valid_ordering'

    # The :type of the error generated for a non-matching object.
    TYPE = 'cuprum.collections.constraints.is_not_valid_ordering'

    # @param options [Hash<Symbol, Object>] Configuration options for the
    #   constraint. Defaults to an empty Hash.
    def initialize(optional: nil, required: nil, **options)
      super(
        attribute_name_constraint,
        attributes_array_constraint,
        attributes_hash_constraint,
        **resolve_required_option(
          optional: optional,
          required: required,
          **options
        )
      )
    end

    def matches?(actual)
      return true if optional? && actual.nil?

      super
    end
    alias match? matches?

    # (see Stannum::Constraints::Base#with_options)
    def with_options(**options)
      super(**resolve_required_option(**options))
    end

    private

    def attribute_name_constraint
      Cuprum::Collections::Constraints::AttributeName.new
    end

    def attributes_array_constraint
      Stannum::Constraints::Types::Array.new(
        allow_empty: false,
        item_type:   attribute_name_constraint
      )
    end

    def attributes_hash_constraint
      Stannum::Constraints::Types::Hash.new(
        allow_empty: false,
        key_type:    attribute_name_constraint,
        value_type:  sort_direction_constraint
      )
    end

    def sort_direction_constraint
      Cuprum::Collections::Constraints::SortDirection.new
    end
  end
end
