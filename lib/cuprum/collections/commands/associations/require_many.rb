# frozen_string_literal: true

require 'cuprum/collections/commands/associations'
require 'cuprum/collections/commands/associations/require_many'
require 'cuprum/collections/errors/associations/not_found'

module Cuprum::Collections::Commands::Associations
  # Command for querying required entities by association.
  class RequireMany < Cuprum::Collections::Commands::Associations::FindMany
    private

    def find_missing_keys(entities:, expected_keys:)
      expected_keys - map_entity_keys(entities: entities)
    end

    def map_entity_keys(entities:)
      entities.map { |entity| entity[association.query_key_name] }
    end

    def missing_keys_error(missing_keys:)
      Cuprum::Collections::Errors::Associations::NotFound.new(
        attribute_name:  association.query_key_name,
        attribute_value: singular? ? missing_keys.first : missing_keys,
        collection_name: association.name,
        primary_key:     association.primary_key_query?
      )
    end

    def perform_query(association:, expected_keys:)
      entities     = step { super }
      missing_keys = find_missing_keys(
        entities:      entities,
        expected_keys: expected_keys
      )

      return success(entities) if missing_keys.empty?

      error = missing_keys_error(missing_keys: missing_keys)

      failure(error)
    end
  end
end
