# frozen_string_literal: true

require 'cuprum/error'

require 'cuprum/collections/errors'

module Cuprum::Collections::Errors
  # An error returned when a query is created with invalid filter parameters.
  class InvalidQuery < Cuprum::Error
    # Short string used to identify the type of error.
    TYPE = 'cuprum.collections.errors.invalid_query'

    # @param query [Object] the given filter parameters, if any.
    # @param message [String] the message to display.
    def initialize(query:, message: nil)
      @query = query

      super(
        message: message || default_message,
        query:
      )
    end

    # @return [Object] the given filter parameters, if any.
    attr_reader :query

    private

    def as_json_data
      {
        'query' => (query.respond_to?(:as_json) ? query.as_json : query.inspect)
      }
    end

    def default_message
      'unable to parse query'
    end
  end
end
