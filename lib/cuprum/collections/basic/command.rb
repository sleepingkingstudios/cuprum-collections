# frozen_string_literal: true

require 'stannum/constraints/types/array_type'

require 'cuprum/collections/basic'

module Cuprum::Collections::Basic
  # Abstract base class for basic collection commands.
  class Command < Cuprum::Collections::CollectionCommand
    # @return [Array<Hash>] the current data in the collection.
    def data
      collection.data
    end

    # @return [Stannum::Constraints::Base, nil] the default contract for
    #   validating items in the collection.
    def default_contract
      @default_contract ||= collection.default_contract
    end

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
