# frozen_string_literal: true

require 'cuprum/parameter_validation'

require 'cuprum/collections/adaptable/commands'

module Cuprum::Collections::Adaptable::Commands
  # Abstract implementation of the AssignOne command for adaptable collections.
  module AbstractAssignOne
    include Cuprum::ParameterValidation

    # @!method call(attributes:, entity:)
    #   Merges the given attributes into the given entity.
    #
    #   @param attributes [Hash] the attributes to merge into the entity.
    #   @param entity [Object] the entity to update.
    #
    #   @return [Object] an instance of the entity class with the updated
    #     attributes.
    validate :attributes
    validate :entity

    private

    def process(attributes:, entity:) = adapter.merge(attributes:, entity:)
  end
end
