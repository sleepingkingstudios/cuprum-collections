# frozen_string_literal: true

require 'bronze/commands'

module Bronze::Commands
  # Shared functionality for defining commands that query the collection.
  #
  # @deprecated [0.6.0]
  module QueryCommand
    # @overload initialize(query:, **options)
    #   @param query [#call] the query object used to access the collection
    #     data.
    #   @param options [Hash] additional options for the collection.
    def initialize(query:, **)
      super(**)

      SleepingKingStudios::Tools::Toolbelt
        .instance
        .core_tools
        .deprecate('Bronze::Commands::QueryCommand')

      @query = query
    end

    # @return [#call] the query object used to access the collection data.
    attr_reader :query
  end
end
