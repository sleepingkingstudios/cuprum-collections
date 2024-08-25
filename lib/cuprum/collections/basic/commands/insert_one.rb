# frozen_string_literal: true

require 'stannum/constraints/types/hash_with_string_keys'

require 'cuprum/collections/basic/command'
require 'cuprum/collections/basic/commands'
require 'cuprum/collections/errors/already_exists'

module Cuprum::Collections::Basic::Commands
  # Command for inserting an entity into the collection.
  class InsertOne < Cuprum::Collections::Basic::Command
    # @!method call(entity:)
    #   Inserts the entity into the collection.
    #
    #   If the collection already includes an entity with the same primary key,
    #   #call will fail and the collection will not be updated.
    #
    #   @param entity [Hash] The collection entity to persist.
    #
    #   @return [Cuprum::Result<Hash>] the persisted entity.
    validate_parameters :call do
      keyword :entity,
        Stannum::Constraints::Types::HashWithStringKeys.new
    end

    private

    def find_existing(entity:)
      value = entity[primary_key_name.to_s]
      index = data.index { |item| item[primary_key_name.to_s] == value }

      return if index.nil?

      error = Cuprum::Collections::Errors::AlreadyExists.new(
        attribute_name:  primary_key_name,
        attribute_value: value,
        collection_name:,
        primary_key:     true
      )
      failure(error)
    end

    def process(entity:)
      step { find_existing(entity:) }

      data << tools.hash_tools.deep_dup(entity)

      entity
    end
  end
end
