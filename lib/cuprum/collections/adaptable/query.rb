# frozen_string_literal: true

require 'cuprum/collections/adaptable'
require 'cuprum/collections/query'

module Cuprum::Collections::Adaptable
  # Abstract base class for adaptable collection Query implementations.
  module Query
    # Exception raised when the query cannot convert native data.
    class AbstractQueryError < StandardError; end

    # Exception raised when converting attributes returns a failing result.
    class InvalidDataError < StandardError; end

    # @todo: Two exception classes here.
    #   - Not implemented/abstract query.
    #   - Internal data error - converting from native/using adapter failed.

    # @param adapter [Cuprum::Collections::Adapter] the collection adapter.
    # @param scope [Cuprum::Collections::Scopes::Base] the base scope for the
    #   query. Defaults to nil.
    def initialize(*, adapter:, **)
      super(*, **)

      @adapter = adapter
    end

    # @return [Cuprum::Collections::Adapter] the collection adapter.
    attr_reader :adapter

    # Converts a native data representation to the adapter entity format.
    #
    # @param native [Object] the native representation of one collection item.
    #
    # @return [Object] the collection item in the format specified by the
    #   adapter.
    def convert(native)
      attributes = convert_native_to_attributes(native)
      result     = adapter.build(attributes:)

      return result.value if result.success?

      # This is an internal data error, not resolvable by the user.
      raise InvalidDataError,
        invalid_data_error_message(attributes:, error: result.error, native:)
    end

    private

    def convert_native_to_attributes(_)
      raise AbstractQueryError,
        "#{self.class.name} is an abstract class - define a subclass and " \
        'implement the #convert_native_to_attributes method'
    end

    def invalid_data_error_message(attributes:, error:, native:)
      message = 'Unable to process query data'

      if error
        message += " - #{error.message}" if error.message
        message += "\n  error details: #{error.as_json}"
      end

      message += "\n  raw data: #{native.inspect}"
      message += "\n  attributes: #{attributes.inspect}"

      message
    end
  end
end
