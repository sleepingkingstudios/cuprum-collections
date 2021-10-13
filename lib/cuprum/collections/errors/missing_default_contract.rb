# frozen_string_literal: true

require 'cuprum/error'

require 'cuprum/collections/errors'

module Cuprum::Collections::Errors
  # Error returned when validating an entity without a contract.
  class MissingDefaultContract < Cuprum::Error
    # Short string used to identify the type of error.
    TYPE = 'cuprum.collections.errors.missing_default_contract'

    # @param entity_class [Class] The class of the assigned entity.
    def initialize(entity_class:)
      @entity_class = entity_class

      super(
        entity_class: entity_class,
        message:      default_message
      )
    end

    # @return [Class] the class of the assigned entity.
    attr_reader :entity_class

    # @return [Hash] a serializable hash representation of the error.
    def as_json
      {
        'data'    => {
          'entity_class' => entity_class.name
        },
        'message' => message,
        'type'    => type
      }
    end

    # @return [String] short string used to identify the type of error.
    def type
      TYPE
    end

    private

    def default_message
      "attempted to validate a #{entity_class.name}, but #{entity_class.name}" \
        ' does not define a default contract'
    end
  end
end
