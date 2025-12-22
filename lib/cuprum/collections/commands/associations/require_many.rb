# frozen_string_literal: true

require 'cuprum/collections/commands/associations'
require 'cuprum/collections/commands/associations/require_many'
require 'cuprum/collections/errors/not_found'

module Cuprum::Collections::Commands::Associations
  # Command for querying required entities by association.
  class RequireMany < Cuprum::Collections::Commands::Associations::FindMany
    private

    def find_missing_keys(entities:, expected_keys:)
      expected_keys - map_entity_keys(entities:)
    end

    def map_entity_keys(entities:)
      entities.map { |entity| entity[association.query_key_name] }
    end

    def missing_keys_error(missing_keys:, plural:)
      attribute_value =
        !plural && missing_keys.is_a?(Array) ? missing_keys.first : missing_keys

      Cuprum::Collections::Errors::NotFound.new(
        attribute_name:  association.query_key_name,
        attribute_value:,
        name:            association.name,
        primary_key:     association.primary_key_query?
      )
    end

    def perform_query(association:, expected_keys:, plural:, **)
      entities     = step { super }
      missing_keys = find_missing_keys(
        entities:,
        expected_keys:
      )

      return success(entities) if missing_keys.empty?

      missing_keys = missing_keys.first unless plural
      error        =
        missing_keys_error(missing_keys:, plural:)

      failure(error)
    end
  end
end
