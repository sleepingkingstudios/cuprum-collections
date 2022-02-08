# frozen_string_literal: true

require 'forwardable'

require 'cuprum/collections'

module Cuprum::Collections
  # A repository represents a group of collections.
  #
  # Conceptually, a repository represents one or more underlying data stores. An
  # application might have one repository for each data store, e.g. one
  # repository for relational data, a second repository for document-based data,
  # and so on. The application may instead aggregate all of its collections into
  # a single repository, relying on the shared interface of all Collection
  # implementations.
  class Repository
    extend Forwardable

    # Error raised when trying to add an existing collection to the repository.
    class DuplicateCollectionError < StandardError; end

    # Error raised when trying to add an invalid collection to the repository.
    class InvalidCollectionError < StandardError; end

    # Error raised when trying to access a collection that is not defined.
    class UndefinedCollectionError < StandardError; end

    def initialize
      @collections = {}
    end

    # @!method keys
    #   Returns the names of the collections in the repository.
    #
    #   @return [Array<String>] the collection names.

    def_delegators :@collections, :keys

    # Finds and returns the collection with the given name.
    #
    # @param qualified_name [String, Symbol] The qualified name of the
    #   collection to return.
    #
    # @return [Object] the requested collection.
    #
    # @raise [Cuprum::Collection::Repository::UndefinedCOllectionError] if the
    #   requested collection is not in the repository.
    def [](qualified_name)
      @collections.fetch(qualified_name.to_s) do
        raise UndefinedCollectionError,
          "repository does not define collection #{qualified_name.inspect}"
      end
    end

    # Adds the collection to the repository.
    #
    # The collection must implement the #collection_name property. Repository
    # subclasses may enforce additional requirements.
    #
    # @param collection [#collection_name] The collection to add to the
    #   repository.
    # @param force [true, false] If true, override an existing collection with
    #   the same name.
    #
    # @return [Cuprum::Rails::Repository] the repository.
    #
    # @raise [DuplicateCollectionError] if a collection with the same name
    #   already exists in the repository.
    def add(collection, force: false)
      validate_collection!(collection)

      if !force && key?(collection.qualified_name.to_s)
        raise DuplicateCollectionError,
          "collection #{collection.qualified_name} already exists"
      end

      @collections[collection.qualified_name.to_s] = collection

      self
    end
    alias << add

    # Checks if a collection with the given name exists in the repository.
    #
    # @param qualified_name [String, Symbol] The name to check for.
    #
    # @return [true, false] true if the key exists, otherwise false.
    def key?(qualified_name)
      @collections.key?(qualified_name.to_s)
    end

    private

    def valid_collection?(collection)
      collection.respond_to?(:collection_name)
    end

    def validate_collection!(collection)
      return if valid_collection?(collection)

      raise InvalidCollectionError,
        "#{collection.inspect} is not a valid collection"
    end
  end
end
