# frozen_string_literal: true

require 'stannum/constraints/types/array_type'
require 'stannum/constraints/types/hash_type'
require 'stannum/constraints/union'
require 'stannum/support/optional'

require 'cuprum/collections/constraints'
require 'cuprum/collections/constraints/attribute_name'
require 'cuprum/collections/constraints/sort_direction'

module Cuprum::Collections::Constraints
  # Asserts that the object is a valid query ordering.
  #
  # A valid ordering can be any of the following:
  # - An attribute name (a non-empty string or symbol).
  #   e.g. 'name' or :title
  # - An array of attribute names
  #   e.g. ['author', 'title']
  # - A hash with attribute key names, whose values are valid sort directions.
  #   e.g. { author: :ascending, title: :descending }
  #
  # Valid sort directions are :ascending and :descending (or :asc and :desc),
  # and can be either strings or symbols.
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

    # Creates a copy of the constraint and updates the copy's options.
    #
    # @param options [Hash] The options to update.
    #
    # @return [Stannum::Constraints::Base] the copied constraint.
    def with_options(**options)
      super(**resolve_required_option(**options))
    end

    private

    def attribute_name_constraint
      Cuprum::Collections::Constraints::AttributeName.new
    end

    def attributes_array_constraint
      Stannum::Constraints::Types::ArrayType.new(
        allow_empty: false,
        item_type:   attribute_name_constraint
      )
    end

    def attributes_hash_constraint
      Stannum::Constraints::Types::HashType.new(
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
