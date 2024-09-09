# frozen_string_literal: true

require 'cuprum/command_factory'

require 'cuprum/collections/basic'
require 'cuprum/collections/basic/commands'
require 'cuprum/collections/basic/scopes/all_scope'
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
        entity_class:,
        qualified_name:,
        **parameters
      )

      @data = data
    end

    # @return [Array<Hash>] the current data in the collection.
    attr_reader :data

    command :assign_one do
      Cuprum::Collections::Basic::Commands::AssignOne.new(collection: self)
    end

    command :build_one do
      Cuprum::Collections::Basic::Commands::BuildOne.new(collection: self)
    end

    command :destroy_one do
      Cuprum::Collections::Basic::Commands::DestroyOne.new(collection: self)
    end

    command :find_many do
      Cuprum::Collections::Basic::Commands::FindMany.new(collection: self)
    end

    command :find_matching do
      Cuprum::Collections::Basic::Commands::FindMatching.new(collection: self)
    end

    command :find_one do
      Cuprum::Collections::Basic::Commands::FindOne.new(collection: self)
    end

    command :insert_one do
      Cuprum::Collections::Basic::Commands::InsertOne.new(collection: self)
    end

    command :update_one do
      Cuprum::Collections::Basic::Commands::UpdateOne.new(collection: self)
    end

    command :validate_one do
      Cuprum::Collections::Basic::Commands::ValidateOne.new(collection: self)
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
      Cuprum::Collections::Basic::Query.new(data, scope:)
    end

    protected

    def comparable_options
      @comparable_options ||= super.merge(
        data:,
        default_contract:
      )
    end

    private

    def default_scope
      Cuprum::Collections::Basic::Scopes::AllScope.new
    end
  end
end
