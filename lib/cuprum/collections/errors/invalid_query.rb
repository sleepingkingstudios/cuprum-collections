# frozen_string_literal: true

require 'cuprum/error'

require 'cuprum/collections/errors'

module Cuprum::Collections::Errors
  # An error returned when a query is created with invalid filter parameters.
  class InvalidQuery < Cuprum::Error
    # Short string used to identify the type of error.
    TYPE = 'cuprum.collections.errors.invalid_query'

    # @param errors [Stannum::Errors] The errors returned by the query builder.
    # @param strategy [Symbol] The strategy used to construct the query.
    def initialize(errors:, strategy:, message: nil)
      @errors   = errors
      @strategy = strategy

      super(
        errors:   errors,
        message:  message || default_message,
        strategy: strategy
      )
    end

    # @return [Stannum::Errors] the errors returned by the query builder.
    attr_reader :errors

    # @return [Symbol] the strategy used to construct the query.
    attr_reader :strategy

    # @return [Hash] a serializable hash representation of the error.
    def as_json
      {
        'data'    => {
          'errors'   => errors.to_a,
          'strategy' => strategy
        },
        'message' => message,
        'type'    => type
      }
    end

    # @return [String] short string used to identify the type of error.
    def type
      TYPE
    end

    private

    def default_message
      "unable to parse query with strategy #{strategy.inspect}"
    end
  end
end
