# frozen_string_literal: true

require 'stannum/constraints/types/array'

require 'cuprum/collections/basic'

module Cuprum::Collections::Basic
  # Abstract base class for basic collection commands.
  class Command < Cuprum::Collections::Command
    # @param collection_name [String, Symbol] The name of the collection.
    # @param data [Array<Hash>] The current data in the collection.
    # @param primary_key_name [Symbol] The name of the primary key attribute.
    #   Defaults to :id.
    # @param primary_key_type [Class, Stannum::Constraint] The type of the
    #   primary key attribute. Defaults to Integer.
    # @param options [Hash<Symbol>] Additional options for the command.
    def initialize(
      collection_name:,
      data:,
      primary_key_name: :id,
      primary_key_type: Integer,
      **options
    )
      super()

      @collection_name  = collection_name.to_s
      @data             = data
      @options          = options
      @primary_key_name = primary_key_name
      @primary_key_type = primary_key_type
    end

    # @return [String] the name of the collection.
    attr_reader :collection_name

    # @return [Array<Hash>] the current data in the collection.
    attr_reader :data

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
          Stannum::Constraints::Types::Array.new(item_type: type)
      end
    end

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
    end

    def validate_primary_key(primary_key)
      match_parameters_to_contract(
        contract:    primary_key_contract,
        keywords:    { primary_key: primary_key },
        method_name: :call
      )
    end

    def validate_primary_keys(primary_keys)
      match_parameters_to_contract(
        contract:    primary_keys_contract,
        keywords:    { primary_keys: primary_keys },
        method_name: :call
      )
    end
  end
end
