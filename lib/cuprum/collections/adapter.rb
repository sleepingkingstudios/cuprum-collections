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
    # @option options allow_extra_attributes [true, false] if false, attributes
    #   methods return an error for attributes not in attributes_names. Defaults
    #   to true if attribute_names is empty, otherwise false.
    # @option options attributes_names [Array<String, Symbol>] the valid
    #   attribute names for a data object. Defaults to [].
    # @option options default_contract [Stannum::Constraints:Base] the contract
    #   used to validate instances of the data object.
    # @option options entity_class [Class] the class of the data objects.
    def initialize(**options) # rubocop:disable Metrics/MethodLength
      @attribute_names =
        options
          .fetch(:attribute_names, [])
          .compact
          .map(&:to_s)
          .then { |ary| Set.new(ary) }
      @default_contract       = options[:default_contract]
      @entity_class           = options[:entity_class]
      @allow_extra_attributes =
        options.fetch(:allow_extra_attributes, @attribute_names.empty?)

      validate_entity_class(@entity_class)
    end

    # @return [Set<String>] the valid attribute names for a data object.
    attr_reader :attribute_names

    # @return [Stannum::Constraints:Base] the contract used to validate
    #   instances of the data object.
    attr_reader :default_contract

    # @return [Class] the class of the data objects.
    attr_reader :entity_class

    # @return [true, false] if false, attributes methods return an error for
    #   attributes not in attributes_names.
    def allow_extra_attributes?
      @allow_extra_attributes
    end

    # Generates a data object from an attributes hash.
    #
    # @param attributes [Hash] the attributes used to initialize the object.
    #
    # @return [Cuprum::Result<Object>] the result with the generated object or
    #   the error.
    def build(attributes:)
      steps do
        handle_invalid_parameters(
          validate_attributes(attributes),
          *validate_attribute_keys(attributes)
        )
        handle_extra_attributes(attributes)

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
          *validate_attribute_keys(attributes),
          validate_entity(entity)
        )
        handle_extra_attributes(attributes)

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

    def extra_attributes_error(extra_attributes:)
      Cuprum::Collections::Errors::ExtraAttributes.new(
        entity_class:,
        extra_attributes:,
        valid_attributes: attribute_names.to_a
      )
    end

    def failed_validation_error(errors:)
      Cuprum::Collections::Errors::FailedValidation.new(
        entity_class:,
        errors:
      )
    end

    def handle_extra_attributes(attributes)
      step do
        return if allow_extra_attributes?

        extra_attributes = attributes.each_key.reject do |key|
          key = key.to_s if key.is_a?(Symbol)

          attribute_names.include?(key)
        end

        return if extra_attributes.empty?

        failure(extra_attributes_error(extra_attributes:))
      end
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

    def validate_attribute_key(key, as:) # rubocop:disable Metrics/MethodLength
      if key.nil?
        return tools.assertions.error_message_for(
          'sleeping_king_studios.tools.assertions.presence',
          as:
        )
      end

      unless key.is_a?(String) || key.is_a?(Symbol)
        return tools.assertions.error_message_for(
          'sleeping_king_studios.tools.assertions.name',
          as:
        )
      end

      return unless key.empty?

      tools.assertions.error_message_for(
        'sleeping_king_studios.tools.assertions.presence',
        as:
      )
    end

    def validate_attribute_keys(attributes, as: 'attributes')
      return unless attributes.is_a?(Hash)

      prefix = "#{tools.string_tools.singularize(as)} key"

      attributes.each_key.with_object([]) do |key, errors|
        message = validate_attribute_key(key, as: "#{prefix} #{key.inspect}")

        errors << message if message
      end
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
