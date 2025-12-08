# frozen_string_literal: true

require 'cuprum/collections/adapter'
require 'cuprum/collections/adapters'

module Cuprum::Collections::Adapters
  # Utility class for converting between attributes and a Stannum::Entity class.
  class EntityAdapter < Cuprum::Collections::Adapter
    # @param options [Hash] options for initializing the adapter.
    #
    # @option options attributes_names [Array<String, Symbol>] the valid
    #   attribute names for a data object. Defaults to the entity class's
    #   attributes. Must be a subset of the entity class's attributes.
    # @option options default_contract [Stannum::Constraints:Base] the contract
    #   used to validate instances of the data object.
    # @option options entity_class [Class] the class of the data objects. Must
    #   be a Stannum::Enttiy subclass.
    def initialize(entity_class:, **options)
      if options[:allow_extra_attributes]
        raise ArgumentError, 'adapter does not support extra attributes'
      end

      attribute_names = options.fetch(:attribute_names) do
        entity_class?(entity_class) ? entity_class&.attributes&.keys || [] : []
      end

      super(attribute_names:, entity_class:, **options)

      verify_attribute_names_are_attributes
    end

    private

    def build_entity(attributes:)
      entity_class.new(**attributes)
    end

    def default_contract_for(**)
      return default_contract if default_contract

      entity_class.contract
    end

    def entity_class?(entity_class)
      entity_class.is_a?(Class) && entity_class < Stannum::Entity
    end

    def merge_entity(attributes:, entity:)
      entity.dup.tap { |copy| copy.assign_attributes(attributes) }
    end

    def serialize_entity(entity:)
      entity.attributes
    end

    def validate_entity_class(entity_class)
      tools.assertions.validate_class(entity_class, as: 'entity class')

      return if entity_class < Stannum::Entity

      raise ArgumentError, 'entity class is not a Stannum::Entity'
    end

    def verify_attribute_names_are_attributes
      invalid_names = attribute_names - (entity_class&.attributes&.keys || [])

      return if invalid_names.empty?

      error_message =
        "attribute names #{invalid_names.join(', ')} are not attributes of " \
        "#{entity_class.name || 'the entity class'}"

      raise ArgumentError, error_message
    end
  end
end
