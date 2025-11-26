# frozen_string_literal: true

require 'cuprum'
require 'cuprum/result_helpers'

require 'cuprum/collections'

module Cuprum::Collections
  # Utility class for converting between raw attributes and a data format.
  class Adapter # rubocop:disable Metrics/ClassLength
    include Cuprum::ResultHelpers
    include Cuprum::Steps

    # @param options [Hash] options for initializing the adapter.
    #
    # @option options default_contract [Stannum::Constraints:Base] the contract
    #   used to validate instances of the data object.
    # @option options entity_class [Class] the class of the data objects.
    def initialize(**options)
      @default_contract = options[:default_contract]
      @entity_class     = options[:entity_class]

      validate_entity_class(@entity_class)
    end

    # @return [Stannum::Constraints:Base] the contract used to validate
    #   instances of the data object.
    attr_reader :default_contract

    # @return [Class] the class of the data objects.
    attr_reader :entity_class

    # Generates a data object from an attributes hash.
    #
    # @param attributes [Hash] the attributes used to initialize the object.
    #
    # @return [Cuprum::Result<Object>] the result with the generated object or
    #   the error.
    def build(attributes:)
      steps do
        handle_invalid_parameters(validate_attributes(attributes))

        build_entity(attributes:)
      end
    end

    # Returns a data object with updated attributes.
    #
    # @param attributes [Hash] the attributes used to update the object.
    # @param entity [Object] the data object to update.
    #
    # @return [Cuprum::Result<Object>] the result with the updated object or the
    #   error.
    def merge(attributes:, entity:)
      steps do
        handle_invalid_parameters(
          validate_attributes(attributes),
          validate_entity(entity)
        )

        merge_entity(attributes:, entity:)
      end
    end

    # Generates an attributes hash from a data object.
    #
    # @param entity [Object] the data object to serialize.
    #
    # @return [Cuprum::Result<Object>] the result with the generated attributes
    #   or the error.
    def serialize(entity:)
      steps do
        handle_invalid_parameters(validate_entity(entity))

        serialize_entity(entity:)
      end
    end

    # Validates a data object.
    #
    # @param entity [Object] the data object to validate.
    # @param contract [Stannum::Constraint] the contract used to validate the
    #   data object, if any.
    #
    # @return [Cuprum::Result<Object>] a passing result with the data object, or
    #   the error if the data object is not valid.
    def validate(entity:, contract: nil)
      steps do
        handle_invalid_parameters(validate_entity(entity))

        contract ||= default_contract_for(entity:)

        match, errors = step { match_contract(contract:, entity:) }

        return success(entity) if match

        failure(failed_validation_error(errors:))
      end
    end

    private

    def build_entity(**)
      failure(not_implemented_error)
    end

    def default_contract_for(**)
      default_contract
    end

    def failed_validation_error(errors:)
      Cuprum::Collections::Errors::FailedValidation.new(
        entity_class:,
        errors:
      )
    end

    def handle_invalid_parameters(*messages)
      step do
        failures = messages.compact.reject(&:empty?)

        return if failures.empty?

        failure(invalid_parameters_error(failures:))
      end
    end

    def invalid_parameters_error(failures:)
      Cuprum::Errors::InvalidParameters
        .new(command_class: self.class, failures:)
    end

    def match_contract(contract:, entity:)
      return contract.match(entity) if contract

      match_native_validation(entity:)
    end

    def match_native_validation(**)
      failure(missing_default_contract_error)
    end

    def merge_entity(**)
      failure(not_implemented_error)
    end

    def missing_default_contract_error
      Cuprum::Collections::Errors::MissingDefaultContract.new(entity_class:)
    end

    def not_implemented_error
      Cuprum::Errors::CommandNotImplemented.new(command: self)
    end

    def serialize_entity(**)
      failure(not_implemented_error)
    end

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
    end

    def validate_attributes(attributes, as: 'attributes')
      return if attributes.is_a?(Hash)

      tools.assertions.error_message_for(
        'sleeping_king_studios.tools.assertions.instance_of',
        as:,
        expected: Hash
      )
    end

    def validate_entity(entity, as: 'entity')
      return unless entity_class

      return if entity.is_a?(entity_class)

      tools.assertions.error_message_for(
        'sleeping_king_studios.tools.assertions.instance_of',
        as:,
        expected: entity_class
      )
    end

    def validate_entity_class(*) = nil
  end
end
