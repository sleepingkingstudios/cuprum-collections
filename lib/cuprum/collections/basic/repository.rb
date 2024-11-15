# frozen_string_literal: true

require 'cuprum/collections/basic'
require 'cuprum/collections/basic/collection'
require 'cuprum/collections/relations/parameters'
require 'cuprum/collections/repository'

module Cuprum::Collections::Basic
  # A repository represents a group of Basic collections.
  class Repository < Cuprum::Collections::Repository
    # @param data [Hash<String, Object>] Seed data to use when building
    #   collections.
    def initialize(data: {})
      super()

      @data = data
    end

    private

    def build_collection(data: nil, **parameters)
      validate_data!(data)

      qualified_name =
        Cuprum::Collections::Relations::Parameters
          .resolve_parameters(parameters)
          .fetch(:qualified_name)

      data ||= @data.fetch(qualified_name, [])

      Cuprum::Collections::Basic.new(data:, **parameters)
    end

    def valid_collection?(collection)
      collection.is_a?(Cuprum::Collections::Basic::Collection)
    end

    def validate_data!(data)
      return if data.nil? || data.is_a?(Array)

      raise ArgumentError, 'data must be an Array of Hashes'
    end
  end
end
