# frozen_string_literal: true

require 'stannum/constraints/types/array_type'
require 'stannum/constraints/types/hash_type'
require 'stannum/constraints/union'
require 'stannum/support/optional'

require 'cuprum/collections/constraints'
require 'cuprum/collections/constraints/attribute_name'
require 'cuprum/collections/constraints/order/attributes_array'
require 'cuprum/collections/constraints/order/attributes_hash'
require 'cuprum/collections/constraints/order/complex_ordering'

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
  # - An array of attribute names, followed by a valid hash.
  #   e.g. ['author', { title: :descending }]
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
        *ordering_constraints,
        **resolve_required_option(
          optional: optional,
          required: required,
          **options
        )
      )
    end

    # @todo
    def errors_for(_actual, errors: nil)
      (errors || Stannum::Errors.new).add(type)
    end

    # @todo
    def matches?(actual)
      return true if optional? && actual.nil?

      super
    end
    alias match? matches?

    # @todo
    def negated_errors_for(_actual, errors: nil)
      (errors || Stannum::Errors.new).add(negated_type)
    end

    # Creates a copy of the constraint and updates the copy's options.
    #
    # @param options [Hash] The options to update.
    #
    # @return [Stannum::Constraints::Base] the copied constraint.
    def with_options(**options)
      super(**resolve_required_option(**options))
    end

    private

    def ordering_constraints
      [
        Cuprum::Collections::Constraints::AttributeName.instance,
        Cuprum::Collections::Constraints::Order::AttributesArray.instance,
        Cuprum::Collections::Constraints::Order::AttributesHash.instance,
        Cuprum::Collections::Constraints::Order::ComplexOrdering.instance
      ]
    end
  end
end
