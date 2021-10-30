# frozen_string_literal: true

require 'cuprum/collections/basic'
require 'cuprum/collections/basic/collection'
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

    # Adds a new collection with the given name to the repository.
    #
    # @param collection_name [String] The name of the new collection.
    # @param data [Hash<String, Object>] The inital data for the collection. If
    #   not specified, defaults to the data used to initialize the repository.
    # @param options [Hash] Additional options to pass to Collection.new
    #
    # @return [Cuprum::Collections::Basic::Collection] the created collection.
    #
    # @see Cuprum::Collections::Basic::Collection#initialize.
    def build(collection_name:, data: nil, **options)
      validate_collection_name!(collection_name)
      validate_data!(data)

      collection = Cuprum::Collections::Basic.new(
        collection_name: collection_name,
        data:            data || @data.fetch(collection_name.to_s, []),
        **options
      )

      add(collection)

      collection
    end

    private

    def valid_collection?(collection)
      collection.is_a?(Cuprum::Collections::Basic::Collection)
    end

    def validate_collection_name!(name)
      raise ArgumentError, "collection name can't be blank" if name.nil?

      unless name.is_a?(String) || name.is_a?(Symbol)
        raise ArgumentError, 'collection name must be a String or Symbol'
      end

      return unless name.empty?

      raise ArgumentError, "collection name can't be blank"
    end

    def validate_data!(data)
      return if data.nil? || data.is_a?(Array)

      raise ArgumentError, 'data must be an Array of Hashes'
    end
  end
end
