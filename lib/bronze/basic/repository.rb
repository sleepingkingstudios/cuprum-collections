# frozen_string_literal: true

require 'bronze/basic'
require 'bronze/basic/collection'
require 'bronze/relations/parameters'
require 'bronze/repository'

module Bronze::Basic
  # A repository represents a group of Basic collections.
  class Repository < Bronze::Repository
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
        Bronze::Relations::Parameters
          .resolve_parameters(parameters)
          .fetch(:qualified_name)

      data ||= @data.fetch(qualified_name, [])

      Bronze::Basic::Collection.new(data:, **parameters)
    end

    def valid_collection?(collection)
      collection.is_a?(Bronze::Basic::Collection)
    end

    def validate_data!(data)
      return if data.nil? || data.is_a?(Array)

      raise ArgumentError, 'data must be an Array of Hashes'
    end
  end
end
