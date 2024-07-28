# frozen_string_literal: true

require 'cuprum/collections/commands'
require 'cuprum/collections/commands/query_command'
require 'cuprum/collections/errors/not_found'

module Cuprum::Collections::Commands
  # Abstract implementation of the FindMany command.
  module AbstractFindMany
    include Cuprum::Collections::Commands::QueryCommand

    private

    def apply_query(primary_keys:)
      key = primary_key_name

      query.where { { key => one_of(primary_keys) } }
    end

    def build_results(items:, primary_keys:)
      primary_keys.map do |primary_key_value|
        next success(items[primary_key_value]) if items.key?(primary_key_value)

        failure(not_found_error(primary_key_value))
      end
    end

    def build_result_list(results, allow_partial:, envelope:)
      return Cuprum::ResultList.new(*results, allow_partial:) unless envelope

      value = envelope ? wrap_items(results.map(&:value)) : nil

      Cuprum::ResultList.new(
        *results,
        allow_partial:,
        value:
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
        collection_name:,
        primary_key:     true
      )
    end

    def process(primary_keys:, allow_partial: false, envelope: false)
      query   = apply_query(primary_keys:)
      items   = items_with_primary_keys(items: query.to_a)
      results = build_results(items:, primary_keys:)

      build_result_list(
        results,
        allow_partial:,
        envelope:
      )
    end

    def wrap_items(items)
      { collection_name => items }
    end
  end
end
