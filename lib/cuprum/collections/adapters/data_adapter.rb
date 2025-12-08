# frozen_string_literal: true

require 'cuprum/collections/adapter'
require 'cuprum/collections/adapters'

module Cuprum::Collections::Adapters
  # Utility class for converting between raw attributes and a Data class.
  class DataAdapter < Cuprum::Collections::Adapter
    # @param options [Hash] options for initializing the adapter.
    #
    # @option options attributes_names [Array<String, Symbol>] the valid
    #   attribute names for a data object. Defaults to the entity class's
    #   members. Must be a subset of the entity class's members.
    # @option options default_contract [Stannum::Constraints:Base] the contract
    #   used to validate instances of the data object.
    # @option options entity_class [Class] the class of the data objects. Must
    #   be a Data subclass.
    def initialize(entity_class:, **options)
      if options[:allow_extra_attributes]
        raise ArgumentError, 'adapter does not support extra attributes'
      end

      attribute_names = options.fetch(:attribute_names) do
        data_class?(entity_class) ? entity_class.members : []
      end

      super(attribute_names:, entity_class:, **options)

      verify_attribute_names_are_members
    end

    private

    def build_entity(attributes:)
      attributes = empty_attributes.merge(attributes)

      entity_class.new(**attributes)
    end

    def data_class?(entity_class)
      entity_class.is_a?(Class) && entity_class < Data
    end

    def empty_attributes
      @empty_attributes ||= member_names.to_h { |key| [key, nil] }
    end

    def member_names
      @member_names ||= entity_class.members.map(&:to_s)
    end

    def merge_entity(attributes:, entity:)
      attributes = entity.to_h.merge(attributes)

      entity_class.new(**attributes)
    end

    def serialize_entity(entity:)
      tools.hash_tools.convert_keys_to_strings(entity.to_h)
    end

    def validate_entity_class(entity_class)
      tools.assertions.validate_class(entity_class, as: 'entity class')

      return if entity_class < Data

      raise ArgumentError, 'entity class is not a subclass of Data'
    end

    def verify_attribute_names_are_members
      invalid_names = attribute_names - member_names

      return if invalid_names.empty?

      error_message =
        "attribute names #{invalid_names.join(', ')} are not members of " \
        "#{entity_class.name || 'the entity class'}"

      raise ArgumentError, error_message
    end
  end
end
