# frozen_string_literal: true

require 'stannum/constraints/types/array_type'

require 'cuprum/collections/basic'

module Cuprum::Collections::Basic
  # Abstract base class for basic collection commands.
  class Command < Cuprum::Collections::CollectionCommand
    # Creates a subclass with the given parameters applied to the constructor.
    def self.subclass(**default_options)
      Class.new(self) do
        define_method(:initialize) do |**options|
          super(**default_options.merge(options))
        end
      end
    end

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
      super(collection: nil)

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

    private

    def primary_key_contract
      type = primary_key_type

      @primary_key_contract ||= Stannum::Contracts::ParametersContract.new do
        keyword :primary_key, type
      end
    end

    def primary_keys_contract
      type = primary_key_type

      @primary_keys_contract ||= Stannum::Contracts::ParametersContract.new do
        keyword :primary_keys,
          Stannum::Constraints::Types::ArrayType.new(item_type: type)
      end
    end

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
    end

    def validate_primary_key(primary_key)
      match_parameters_to_contract(
        contract:    primary_key_contract,
        keywords:    { primary_key: },
        method_name: :call
      )
    end

    def validate_primary_keys(primary_keys)
      match_parameters_to_contract(
        contract:    primary_keys_contract,
        keywords:    { primary_keys: },
        method_name: :call
      )
    end
  end
end
