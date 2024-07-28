# frozen_string_literal: true

require 'forwardable'

require 'cuprum/collections'
require 'cuprum/collections/relation'

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

    # Error raised when trying to call an abstract repository method.
    class AbstractRepositoryError < StandardError; end

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
    # @param collection [Cuprum::Collections::Collection] the collection to add
    #   to the repository.
    # @param force [true, false] if true, override an existing collection with
    #   the same name.
    #
    # @return [Cuprum::Collections::Repository] the repository.
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

    # @overload create(collection_name: nil, entity_class: nil, force: false, **options)
    #   Adds a new collection with the given name to the repository.
    #
    #   @param collection_name [String] the name of the new collection.
    #   @param entity_class [Class, String] the class of entity represented in
    #     the collection.
    #   @param force [true, false] if true, override an existing collection with
    #     the same name.
    #   @param options [Hash] additional options to pass to Collection.new.
    #
    #   @return [Cuprum::Collections::Collection] the created collection.
    #
    #   @raise [DuplicateCollectionError] if a collection with the same name
    #     already exists in the repository.
    def create(force: false, **options)
      collection = build_collection(**options)

      add(collection, force:)

      collection
    end

    # @overload find_or_create(collection_name: nil, entity_class: nil, **options)
    #   Finds or creates a new collection with the given name.
    #
    #   @param collection_name [String] the name of the new collection.
    #   @param entity_class [Class, String] the class of entity represented in
    #     the collection.
    #   @param options [Hash] additional options to pass to Collection.new.
    #
    #   @return [Cuprum::Collections::Collection] the created collection.
    #
    #   @raise [DuplicateCollectionError] if a collection with the same name
    #     but different parameters already exists in the repository.
    def find_or_create(**parameters)
      qualified_name = qualified_name_for(**parameters)

      unless key?(qualified_name)
        create(**parameters)

        return @collections[qualified_name]
      end

      collection = @collections[qualified_name]

      return collection if collection.matches?(**parameters)

      raise DuplicateCollectionError,
        "collection #{qualified_name} already exists"
    end

    # Checks if a collection with the given name exists in the repository.
    #
    # @param qualified_name [String, Symbol] The name to check for.
    #
    # @return [true, false] true if the key exists, otherwise false.
    def key?(qualified_name)
      @collections.key?(qualified_name.to_s)
    end

    private

    def build_collection(**)
      raise AbstractRepositoryError,
        "#{self.class.name} is an abstract class. Define a repository " \
        'subclass and implement the #build_collection method.'
    end

    def qualified_name_for(**parameters)
      Cuprum::Collections::Relation::Parameters
        .resolve_parameters(parameters)
        .fetch(:qualified_name)
    end

    def valid_collection?(collection)
      collection.respond_to?(:qualified_name)
    end

    def validate_collection!(collection)
      return if valid_collection?(collection)

      raise InvalidCollectionError,
        "#{collection.inspect} is not a valid collection"
    end
  end
end
