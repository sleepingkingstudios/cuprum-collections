# frozen_string_literal: true

require 'cuprum/collections/basic/command'
require 'cuprum/collections/basic/commands'
require 'cuprum/collections/errors/not_found'

module Cuprum::Collections::Basic::Commands
  # Command for destroying one collection item by primary key.
  class DestroyOne < Cuprum::Collections::Basic::Command
    # @!method call(primary_key:)
    #   Finds and destroys the item with the given primary key.
    #
    #   The command will find the entity with the given primary key and remove
    #   it from the collection. If the entity is not found, the command will
    #   fail and return a NotFound error.
    #
    #   @param primary_key [Object] The primary key of the requested item.
    #
    #   @return [Cuprum::Result<Hash{String, Object}>] a result with the
    #     destroyed item.
    validate_parameters :call do
      keyword :primary_key, Object
    end

    private

    def handle_missing_item(index:, primary_key:)
      return if index

      error = Cuprum::Collections::Errors::NotFound.new(
        collection_name:    collection_name,
        primary_key_name:   primary_key_name,
        primary_key_values: primary_key
      )
      Cuprum::Result.new(error: error)
    end

    def process(primary_key:)
      step { validate_primary_key(primary_key) }

      index = data.index { |item| item[primary_key_name.to_s] == primary_key }

      step { handle_missing_item(index: index, primary_key: primary_key) }

      data.delete_at(index)
    end
  end
end
