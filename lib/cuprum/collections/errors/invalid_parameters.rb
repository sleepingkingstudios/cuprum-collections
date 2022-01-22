# frozen_string_literal: true

require 'cuprum/error'

require 'cuprum/collections/errors'

module Cuprum::Collections::Errors
  # An error returned when a command is called with invalid parameters.
  class InvalidParameters < Cuprum::Error
    # Short string used to identify the type of error.
    TYPE = 'cuprum.collections.errors.invalid_parameters'

    # @param command [Cuprum::Command] the called command.
    # @param errors [Stannum::Errors] the errors returned by the parameters
    #   contract.
    def initialize(command:, errors:)
      @command = command
      @errors  = errors

      super(
        command: command,
        errors:  errors,
        message: "invalid parameters for command #{command.class}"
      )
    end

    # @return [Cuprum::Command] the called command.
    attr_reader :command

    # @return [Stannum::Errors] the errors returned by the parameters contract.
    attr_reader :errors

    private

    def as_json_data
      {
        'command_class' => command.class.name,
        'errors'        => errors.to_a
      }
    end
  end
end
