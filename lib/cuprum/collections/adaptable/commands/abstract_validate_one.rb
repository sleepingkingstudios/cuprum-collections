# frozen_string_literal: true

require 'cuprum/parameter_validation'

require 'cuprum/collections/adaptable/commands'

module Cuprum::Collections::Adaptable::Commands
  # Abstract, adaptable implementation of the ValidateOne command.
  module AbstractValidateOne
    include Cuprum::ParameterValidation

    # @!method call(entity:, contract: nil)
    #   Validates the entity against the given or default contract.
    #
    #   If the entity matches the contract, #call will return a passing result
    #   with the entity as the result value. If the entity does not match the
    #   contract, #call will return a failing result with a FailedValidation
    #   error and the validation errors.
    #
    #   @param contract [Stannum::Constraints:Base] The contract with which to
    #     validate the entity. If not given, the entity will be validated using
    #     the collection's default contract.
    #   @param entity [Hash] The collection entity to validate.
    #
    #   @return [Cuprum::Result<Hash>] the validated entity.
    validate :contract, Stannum::Constraints::Base, optional: true
    validate :entity

    private

    def process(entity:, contract: nil)
      adapter.validate(contract:, entity:)
    end
  end
end
