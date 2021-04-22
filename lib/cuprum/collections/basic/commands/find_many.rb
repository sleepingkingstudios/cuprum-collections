# frozen_string_literal: true

require 'cuprum/collections/basic/command'
require 'cuprum/collections/basic/commands'
require 'cuprum/collections/commands/abstract_find_many'

module Cuprum::Collections::Basic::Commands
  # Command for finding multiple collection items by primary key.
  class FindMany < Cuprum::Collections::Basic::Command
    include Cuprum::Collections::Commands::AbstractFindMany

    # @param allow_partial [Boolean] If true, returns a passing result when at
    #   least one of the requested collection items is found. If false, then all
    #   of the requested items must be found or a failure will be returned.
    # @param collection_name [String, Symbol] The name of the collection.
    # @param data [Array<Hash>] The current data in the collection.
    # @param envelope [Boolean] If true, wraps the result in a Hash.
    # @param options [Hash<Symbol>] Additional options for the command.
    # @param primary_key_name [Symbol] The name of the primary key attribute.
    #   Defaults to :id.
    # @param primary_key_type [Class, Stannum::Constraint] The type of the
    #   primary key attribute. Defaults to Integer.
    def initialize( # rubocop:disable Metrics/ParameterLists
      collection_name:,
      data:,
      allow_partial:    false,
      envelope:         false,
      primary_key_name: :id,
      primary_key_type: Integer,
      **options
    )
      super(
        collection_name:  collection_name,
        data:             data,
        envelope:         envelope,
        primary_key_name: primary_key_name,
        primary_key_type: primary_key_type,
        **options,
      )

      @allow_partial = !!allow_partial # rubocop:disable Style/DoubleNegation
      @envelope      = !!envelope
    end

    # @!method call(primary_keys:)
    #   Queries the collection for the item(s) with the given primary key(s).
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
    #   @param primary_keys [Array] The primary keys of the requested items.
    #
    #   @return [Cuprum::Result<Array<Hash{String, Object}>>] a result with the
    #     requested items.
    validate_parameters :call do
      keyword :primary_keys, Array
    end

    # @return [Boolean] if true, returns a partial result if any items found.
    def allow_partial?
      @allow_partial
    end

    # @return [Boolean] if true, wraps the result in a Hash.
    def envelope?
      @envelope
    end

    private

    def build_query
      Cuprum::Collections::Basic::Query.new(data)
    end

    def items_with_primary_keys(items:)
      # :nocov:
      items.map { |item| [item[primary_key_name.to_s], item] }.to_h
      # :nocov:
    end

    def process(primary_keys:)
      step { validate_primary_keys(primary_keys) }

      super
    end
  end
end
