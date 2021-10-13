# frozen_string_literal: true

require 'stannum/constraints/hashes/indifferent_key'

require 'cuprum/collections/constraints'

module Cuprum::Collections::Constraints
  # Asserts that the object is a non-empty String or Symbol.
  class AttributeName < Stannum::Constraints::Hashes::IndifferentKey
    # The :type of the error generated for a matching object.
    NEGATED_TYPE = 'cuprum.collections.constraints.is_valid_attribute_name'

    # The :type of the error generated for a non-matching object.
    TYPE = 'cuprum.collections.constraints.is_not_valid_attribute_name'

    # @return [Cuprum::Collections::Constraints::AttributeName] a cached
    #   instance of the constraint with default options.
    def self.instance
      @instance ||= new
    end
  end
end
