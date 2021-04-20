# frozen_string_literal: true

require 'cuprum/collections/basic'

module Cuprum::Collections::Basic
  # Abstract base class for basic collection commands.
  class Command < Cuprum::Collections::Command
    # @param collection_name [String, Symbol] The name of the collection.
    # @param data [Array<Hash>] The current data in the collection.
    # @param options [Hash<Symbol>] Additional options for the command.
    def initialize(collection_name:, data:, **options)
      super()

      @collection_name = collection_name.to_s
      @data            = data
      @options         = options
    end

    # @return [String] The name of the collection.
    attr_reader :collection_name

    # @return [Array<Hash>] the current data in the collection.
    attr_reader :data

    # @return [Hash<Symbol>] additional options for the command.
    attr_reader :options
  end
end
