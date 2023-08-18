# frozen_string_literal: true

require 'cuprum/command_factory'

require 'cuprum/collections/basic'
require 'cuprum/collections/basic/commands'
require 'cuprum/collections/collection'

module Cuprum::Collections::Basic
  # Wraps an in-memory array of hashes data store as a Cuprum collection.
  class Collection < Cuprum::Collections::Collection
    # @param collection_name [String, Symbol] the name of the collection.
    # @param data [Array<Hash>] the current data in the collection.
    # @param entity_class [Class, String] the class of entity represented in the
    #   collection.
    # @param options [Hash<Symbol>] additional options for the collection.
    #
    # @option options default_contract [Stannum::Constraints::Base, nil] the
    #   default contract for validating items in the collection.
    # @option options member_name [String] the name of a collection entity.
    # @option options primary_key_name [String] the name of the primary key
    #   attribute. Defaults to 'id'.
    # @option options primary_key_type [Class, Stannum::Constraint] the type of
    #   the primary key attribute. Defaults to Integer.
    # @option options qualified_name [String] the qualified name of the
    #   collection, which should be unique. Defaults to the collection name.
    def initialize(collection_name: nil, data: [], entity_class: nil, **options)
      super(
        collection_name: collection_name,
        entity_class:    entity_class,
        **options
      )

      @data = data
    end

    # @return [Array<Hash>] the current data in the collection.
    attr_reader :data

    command_class :assign_one do
      Cuprum::Collections::Basic::Commands::AssignOne
        .subclass(**command_options)
    end

    command_class :build_one do
      Cuprum::Collections::Basic::Commands::BuildOne
        .subclass(**command_options)
    end

    command_class :destroy_one do
      Cuprum::Collections::Basic::Commands::DestroyOne
        .subclass(**command_options)
    end

    command_class :find_many do
      Cuprum::Collections::Basic::Commands::FindMany
        .subclass(**command_options)
    end

    command_class :find_matching do
      Cuprum::Collections::Basic::Commands::FindMatching
        .subclass(**command_options)
    end

    command_class :find_one do
      Cuprum::Collections::Basic::Commands::FindOne
        .subclass(**command_options)
    end

    command_class :insert_one do
      Cuprum::Collections::Basic::Commands::InsertOne
        .subclass(**command_options)
    end

    command_class :update_one do
      Cuprum::Collections::Basic::Commands::UpdateOne
        .subclass(**command_options)
    end

    command_class :validate_one do
      Cuprum::Collections::Basic::Commands::ValidateOne
        .subclass(**command_options)
    end

    # @return [Stannum::Constraints::Base, nil] the #   default contract for
    #   validating items in the collection.
    def default_contract
      @options[:default_contract]
    end

    # A new Query instance, used for querying against the collection data.
    #
    # @return [Cuprum::Collections::Basic::Query] the query.
    def query
      Cuprum::Collections::Basic::Query.new(data)
    end

    protected

    def command_options
      super().merge(
        data:             data,
        default_contract: default_contract
      )
    end

    private

    def default_entity_class
      Hash
    end
  end
end
