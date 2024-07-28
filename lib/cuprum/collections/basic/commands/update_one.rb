# frozen_string_literal: true

require 'stannum/constraints/types/hash_with_string_keys'

require 'cuprum/collections/basic/command'
require 'cuprum/collections/basic/commands'
require 'cuprum/collections/errors/not_found'

module Cuprum::Collections::Basic::Commands
  # Command for updating an entity in the collection.
  class UpdateOne < Cuprum::Collections::Basic::Command
    # @!method call(entity:)
    #   Updates the entity in the collection.
    #
    #   If the collection does not already have an entity with the same primary
    #   key, #call will fail and the collection will not be updated.
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

      return index unless index.nil?

      error = Cuprum::Collections::Errors::NotFound.new(
        attribute_name:  primary_key_name,
        attribute_value: entity[primary_key_name.to_s],
        collection_name:,
        primary_key:     true
      )
      failure(error)
    end

    def process(entity:)
      index = step { find_existing(entity:) }

      entity = data[index].merge(entity)

      data[index] = entity.dup

      entity
    end
  end
end
