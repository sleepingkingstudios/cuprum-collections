# frozen_string_literal: true

require 'stannum/constraints/types/hash_with_string_keys'

require 'cuprum/collections/basic/command'
require 'cuprum/collections/basic/commands'
require 'cuprum/collections/errors/failed_validation'
require 'cuprum/collections/errors/missing_default_contract'

module Cuprum::Collections::Basic::Commands
  # Command for validating a collection entity.
  class ValidateOne < Cuprum::Collections::Basic::Command
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

    def contract_or_default(contract:, entity:)
      return contract if contract

      return default_contract if default_contract

      error = Cuprum::Collections::Errors::MissingDefaultContract.new(
        entity_class: entity.class
      )
      failure(error)
    end

    def match_entity(contract:, entity:)
      valid, errors = contract.match(entity)

      return if valid

      error = Cuprum::Collections::Errors::FailedValidation.new(
        entity_class: entity.class,
        errors:
      )
      failure(error)
    end

    def process(entity:, contract: nil)
      contract =
        step { contract_or_default(contract:, entity:) }

      step { match_entity(contract:, entity:) }

      entity
    end
  end
end
