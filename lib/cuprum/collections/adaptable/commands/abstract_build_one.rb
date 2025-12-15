# frozen_string_literal: true

require 'cuprum/parameter_validation'

require 'cuprum/collections/adaptable/commands'

module Cuprum::Collections::Adaptable::Commands
  # Abstract implementation of the BuildOne command for adaptable collections.
  module AbstractBuildOne
    include Cuprum::ParameterValidation

    # @!method call(attributes:)
    #   Creates a new entity from the given attributes.
    #
    #   @param attributes [Hash] the attributes to build into an entity.
    #
    #   @return [Object] an instance of the entity class with the given
    #     attributes.
    validate :attributes

    private

    def process(attributes:) = adapter.build(attributes:)
  end
end
