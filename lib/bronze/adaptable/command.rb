# frozen_string_literal: true

require 'bronze/adaptable'

module Bronze::Adaptable
  # Mixin for defining commands for adaptable collections.
  module Command
    # @return [Bronze::Adapter] the adapter defined for the
    #   collection.
    def adapter = collection.adapter

    private

    def validate_attributes(attributes, as: 'attributes')
      adapter.validate_attributes_parameter(attributes, as:)
    end

    def validate_entity(entity, as: 'entity')
      adapter.validate_entity_parameter(entity, as:)
    end
  end
end
