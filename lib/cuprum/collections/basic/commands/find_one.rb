# frozen_string_literal: true

require 'cuprum/collections/basic/command'
require 'cuprum/collections/basic/commands'
require 'cuprum/collections/commands/abstract_find_one'

module Cuprum::Collections::Basic::Commands
  # Command for finding one collection item by primary key.
  class FindOne < Cuprum::Collections::Basic::Command
    include Cuprum::Collections::Commands::AbstractFindOne

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

      @envelope = !!envelope
    end

    # @!method call(primary_key:)
    #   Queries the collection for the item with the given primary key.
    #
    #   The command will find and return the entity with the given primary key.
    #   If the entity is not found, the command will fail and return a NotFound
    #   error.
    #
    #   When the :envelope option is true, the command wraps the item in a Hash,
    #   using the singular name of the collection as the key.
    #
    #   @param primary_key [Object] The primary key of the requested item.
    #
    #   @return [Cuprum::Result<Hash{String, Object}>] a result with the
    #     requested item.
    validate_parameters :call do
      keyword :primary_key, Object
    end

    # @return [Boolean] if true, wraps the result in a Hash.
    def envelope?
      @envelope
    end

    private

    def build_query
      Cuprum::Collections::Basic::Query.new(data)
    end

    def process(primary_key:)
      step { validate_primary_key(primary_key) }

      super
    end
  end
end
