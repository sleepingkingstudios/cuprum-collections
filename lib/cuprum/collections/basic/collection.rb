# frozen_string_literal: true

require 'cuprum/command_factory'

require 'cuprum/collections/basic'
require 'cuprum/collections/basic/commands'
require 'cuprum/collections/basic/scopes/null_scope'
require 'cuprum/collections/collection'

module Cuprum::Collections::Basic
  # Wraps an in-memory array of hashes data store as a Cuprum collection.
  class Collection < Cuprum::Collections::Collection
    # @overload initialize(data: [], entity_class: nil, name: nil, qualified_name: nil, singular_name: nil, **options)
    #   @param data [Array<Hash>] the current data in the collection.
    #   @param entity_class [Class, String] the class of entity represented by
    #     the relation.
    #   @param name [String] the name of the relation.
    #   @param qualified_name [String] a scoped name for the relation.
    #   @param singular_name [String] the name of an entity in the relation.
    #   @param options [Hash] additional options for the relation.
    #
    #   @option options primary_key_name [String] the name of the primary key
    #     attribute. Defaults to 'id'.
    #   @option primary_key_type [Class, Stannum::Constraint] the type of
    #     the primary key attribute. Defaults to Integer.
    def initialize(data: [], entity_class: Hash, **parameters)
      qualified_name = parameters.fetch(:qualified_name) do
        next nil unless entity_class == Hash

        parameters.fetch(:collection_name, parameters[:name])
      end

      super(
        entity_class:   entity_class,
        qualified_name: qualified_name,
        **parameters
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
        .subclass(query: query, **command_options)
    end

    command_class :find_matching do
      Cuprum::Collections::Basic::Commands::FindMatching
        .subclass(query: query, **command_options)
    end

    command_class :find_one do
      Cuprum::Collections::Basic::Commands::FindOne
        .subclass(query: query, **command_options)
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
      Cuprum::Collections::Basic::Query.new(data, scope: scope)
    end

    protected

    def command_options
      super().merge(
        data:             data,
        default_contract: default_contract
      )
    end

    private

    def default_scope
      Cuprum::Collections::Basic::Scopes::NullScope.new
    end
  end
end
