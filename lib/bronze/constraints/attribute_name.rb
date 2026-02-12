# frozen_string_literal: true

require 'stannum/constraints/hashes/indifferent_key'

require 'bronze/constraints'

module Bronze::Constraints
  # Asserts that the object is a non-empty String or Symbol.
  class AttributeName < Stannum::Constraints::Hashes::IndifferentKey
    # The :type of the error generated for a matching object.
    NEGATED_TYPE = 'bronze.constraints.is_valid_attribute_name'

    # The :type of the error generated for a non-matching object.
    TYPE = 'bronze.constraints.is_not_valid_attribute_name'

    # @return [Bronze::Constraints::AttributeName] a cached instance of the
    #   constraint with default options.
    def self.instance
      @instance ||= new
    end
  end
end
