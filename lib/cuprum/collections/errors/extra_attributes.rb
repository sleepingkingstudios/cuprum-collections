# frozen_string_literal: true

require 'cuprum/error'

require 'cuprum/collections/errors'

module Cuprum::Collections::Errors
  # Error returned when assigning invalid attributes to an entity.
  class ExtraAttributes < Cuprum::Error
    # Short string used to identify the type of error.
    TYPE = 'cuprum.collections.errors.extra_attributes'

    # @param entity_class [Class] The class of the assigned entity.
    # @param extra_attributes [Array<String>] The names of the extra attributes
    #   that were assigned to the entity.
    # @param valid_attributes [Array<String>] The names of valid attributes for
    #   the entity.
    def initialize(extra_attributes:, valid_attributes:, entity_class: nil)
      @entity_class     = entity_class
      @extra_attributes = extra_attributes
      @valid_attributes = valid_attributes

      super(
        entity_class:,
        extra_attributes:,
        message:          default_message,
        valid_attributes:
      )
    end

    # @return [Class] the class of the assigned entity.
    attr_reader :entity_class

    # @return [Array<String>] The names of the extra attributes that were
    #   assigned to the entity.
    attr_reader :extra_attributes

    # @return [Array<String>] The names of valid attributes for the entity.
    attr_reader :valid_attributes

    private

    def as_json_data
      {
        'entity_class'     => entity_class&.name,
        'extra_attributes' => extra_attributes,
        'valid_attributes' => valid_attributes
      }
    end

    def default_message
      "invalid attributes for #{entity_class&.name || 'an entity'}: " \
        "#{extra_attributes.join(', ')}"
    end
  end
end
