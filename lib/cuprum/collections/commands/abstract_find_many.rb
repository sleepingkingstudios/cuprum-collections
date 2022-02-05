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

    def apply_query(primary_keys:, scope:)
      key = primary_key_name

      (scope || build_query).where { { key => one_of(primary_keys) } }
    end

    def build_results(items:, primary_keys:)
      primary_keys.map do |primary_key_value|
        next success(items[primary_key_value]) if items.key?(primary_key_value)

        failure(not_found_error(primary_key_value))
      end
    end

    def build_result_list(results, allow_partial:, envelope:)
      unless envelope
        return Cuprum::ResultList.new(*results, allow_partial: allow_partial)
      end

      value = envelope ? wrap_items(results.map(&:value)) : nil

      Cuprum::ResultList.new(
        *results,
        allow_partial: allow_partial,
        value:         value
      )
    end

    def items_with_primary_keys(items:)
      # :nocov:
      items.to_h { |item| [item.send(primary_key_name), item] }
      # :nocov:
    end

    def not_found_error(primary_key_value)
      Cuprum::Collections::Errors::NotFound.new(
        attribute_name:  primary_key_name,
        attribute_value: primary_key_value,
        collection_name: collection_name,
        primary_key:     true
      )
    end

    def process(
      primary_keys:,
      allow_partial: false,
      envelope:      false,
      scope:         nil
    )
      query   = apply_query(primary_keys: primary_keys, scope: scope)
      items   = items_with_primary_keys(items: query.to_a)
      results = build_results(items: items, primary_keys: primary_keys)

      build_result_list(
        results,
        allow_partial: allow_partial,
        envelope:      envelope
      )
    end

    def wrap_items(items)
      { collection_name => items }
    end
  end
end
