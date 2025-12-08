# frozen_string_literal: true

require 'cuprum/error'

require 'cuprum/collections/errors'

module Cuprum::Collections::Errors
  # Error returned when a collection item fails validation.
  class FailedValidation < Cuprum::Error
    # Short string used to identify the type of error.
    TYPE = 'cuprum.collections.errors.failed_validation'

    # @param entity_class [Class] The class of the assigned entity.
    # @param errors [Stannum::Errors] The errors generated when validating the
    #   entity.
    def initialize(errors:, entity_class: nil)
      @entity_class = entity_class
      @errors       = errors

      super(
        entity_class:,
        errors:,
        message:      default_message
      )
    end

    # @return [Class] the class of the assigned entity.
    attr_reader :entity_class

    # @return [Stannum::Errors] The errors generated when validating the entity.
    attr_reader :errors

    private

    def as_json_data
      {
        'entity_class' => entity_class&.name,
        'errors'       => format_errors
      }
    end

    def default_message
      "#{entity_class&.name || 'an entity'} failed validation"
    end

    def format_errors
      errors
        .with_messages
        .group_by_path { |err| err[:message] }
        .transform_keys { |path| path.map(&:to_s).join('.') }
    end
  end
end
