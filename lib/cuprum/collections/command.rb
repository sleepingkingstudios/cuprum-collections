# frozen_string_literal: true

require 'stannum/parameter_validation'

require 'cuprum/collections'
require 'cuprum/collections/errors/invalid_parameters'

module Cuprum::Collections
  # Abstract base class for Cuprum::Collection commands.
  class Command < Cuprum::Command
    extend  Stannum::ParameterValidation
    include Stannum::ParameterValidation

    private

    def handle_invalid_parameters(errors:, method_name:)
      return super unless method_name == :call

      error = Cuprum::Collections::Errors::InvalidParameters.new(
        command: self,
        errors:  errors
      )
      failure(error)
    end
  end
end
