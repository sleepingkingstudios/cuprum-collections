# frozen_string_literal: true

require 'cuprum/parameter_validation'
require 'stannum/constraints/boolean'

require 'cuprum/collections/commands'
require 'cuprum/collections/errors/not_found'

module Cuprum::Collections::Commands
  # Abstract implementation of the FindMany command.
  module AbstractFindMany
    include Cuprum::ParameterValidation

    # @!method call(primary_keys:, allow_partial: false, envelope: false)
    #   Queries the collection for the items with the given primary keys.
    #
    #   The command will find and return the entities with the given primary
    #   keys. If any of the items are not found, the command will fail and
    #   return a NotFound error. If the :allow_partial option is set, the
    #   command will return a partial result unless none of the requested items
    #   are found.
    #
    #   When the :envelope option is true, the command wraps the items in a
    #   Hash, using the name of the collection as the key.
    #
    #   @param allow_partial [Boolean] If true, passes if any of the items are
    #     found.
    #   @param envelope [Boolean] If true, wraps the result value in a Hash.
    #   @param primary_keys [Array] The primary keys of the requested items.
    #
    #   @return [Cuprum::Result<Array<Hash{String, Object}>>] a result with the
    #     requested items.
    validate :allow_partial, :boolean, optional: true
    validate :envelope,      :boolean, optional: true
    validate :primary_keys

    private

    def apply_query(primary_keys:)
      key = primary_key_name

      query.where { |scope| { key => scope.one_of(primary_keys) } }
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
      items.to_h do |item|
        primary_key_value =
          if item.respond_to?(:[])
            item[primary_key_name.to_s] || item[primary_key_name.to_sym]
          else
            item.send(primary_key_name)
          end

        [primary_key_value, item]
      end
      # :nocov:
    end

    def not_found_error(primary_key_value)
      Cuprum::Collections::Errors::NotFound.new(
        attribute_name:  primary_key_name,
        attribute_value: primary_key_value,
        name:,
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
      { name => items }
    end
  end
end
