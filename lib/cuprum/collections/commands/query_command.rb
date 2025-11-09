# frozen_string_literal: true

require 'cuprum/collections/commands'

module Cuprum::Collections::Commands
  # Shared functionality for defining commands that query the collection.
  module QueryCommand
    # @overload initialize(query:, **options)
    #   @param query [#call] the query object used to access the collection
    #     data.
    #   @param options [Hash] additional options for the collection.
    def initialize(query:, **)
      super(**)

      @query = query
    end

    # @return [#call] the query object used to access the collection data.
    attr_reader :query
  end
end
