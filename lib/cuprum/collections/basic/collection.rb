# frozen_string_literal: true

require 'cuprum/command_factory'

require 'cuprum/collections/basic'
require 'cuprum/collections/basic/commands'

module Cuprum::Collections::Basic
  # Wraps an in-memory array of hashes data store as a Cuprum collection.
  class Collection < Cuprum::CommandFactory
    # @param collection_name [String, Symbol] The name of the collection.
    # @param data [Array<Hash>] The current data in the collection.
    # @param default_contract [Stannum::Constraints::Base, nil] The default
    #   contract for validating items in the collection.
    # @param member_name [String] The name of a collection entity.
    # @param primary_key_name [Symbol] The name of the primary key attribute.
    #   Defaults to :id.
    # @param primary_key_type [Class, Stannum::Constraint] The type of the
    #   primary key attribute. Defaults to Integer.
    # @param options [Hash<Symbol>] Additional options for the command.
    def initialize( # rubocop:disable Metrics/ParameterLists
      collection_name:,
      data:,
      default_contract: nil,
      member_name:      nil,
      primary_key_name: :id,
      primary_key_type: Integer,
      **options
    )
      super()

      @collection_name  = collection_name.to_s
      @data             = data
      @default_contract = default_contract
      @member_name      =
        member_name ? member_name.to_s : tools.str.singularize(@collection_name)
      @options          = options
      @primary_key_name = primary_key_name
      @primary_key_type = primary_key_type
    end

    # @return [String] the name of the collection.
    attr_reader :collection_name

    # @return [Array<Hash>] the current data in the collection.
    attr_reader :data

    # @return [Stannum::Constraints::Base, nil] the default contract for
    #   validating items in the collection.
    attr_reader :default_contract

    # @return [String] the name of a collection entity.
    attr_reader :member_name

    # @return [Hash<Symbol>] additional options for the command.
    attr_reader :options

    # @return [Symbol] the name of the primary key attribute.
    attr_reader :primary_key_name

    # @return [Class, Stannum::Constraint] the type of the primary key
    #   attribute.
    attr_reader :primary_key_type

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

    # A new Query instance, used for querying against the collection data.
    #
    # @return [Cuprum::Collections::Basic::Query] the query.
    def query
      Cuprum::Collections::Basic::Query.new(data)
    end

    private

    def command_options
      @command_options ||= {
        collection_name:  collection_name,
        data:             data,
        default_contract: default_contract,
        member_name:      member_name,
        primary_key_name: primary_key_name,
        primary_key_type: primary_key_type,
        **options
      }
    end

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
    end
  end
end
