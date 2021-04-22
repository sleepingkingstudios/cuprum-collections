# frozen_string_literal: true

require 'cuprum/collections/commands'
require 'cuprum/collections/errors/not_found'

module Cuprum::Collections::Commands
  # Abstract implementation of the FindMany command.
  #
  # Subclasses must define the #build_query method, which returns an empty
  # Query instance for that collection.
  module AbstractFindMany
    private

    def apply_query(primary_keys:)
      key = primary_key_name

      build_query.where { { key => one_of(primary_keys) } }
    end

    def handle_missing_items(items:, primary_keys:)
      found, missing = match_items(items: items, primary_keys: primary_keys)

      return found if missing.empty?

      return found if allow_partial? && !found.empty?

      error = Cuprum::Collections::Errors::NotFound.new(
        collection_name:    collection_name,
        primary_key_name:   primary_key_name,
        primary_key_values: missing
      )
      Cuprum::Result.new(error: error)
    end

    def items_with_primary_keys(items:)
      # :nocov:
      items.map { |item| [item.send(primary_key_name), item] }.to_h
      # :nocov:
    end

    def match_items(items:, primary_keys:)
      items   = items_with_primary_keys(items: items)
      found   = []
      missing = []

      primary_keys.each do |key|
        item = items[key]

        item.nil? ? (missing << key) : (found << item)
      end

      [found, missing]
    end

    def process(primary_keys:)
      query = apply_query(primary_keys: primary_keys)
      items = step do
        handle_missing_items(items: query.to_a, primary_keys: primary_keys)
      end

      wrap_items(items)
    end

    def wrap_items(items)
      return items unless options[:envelope]

      { collection_name => items }
    end
  end
end
