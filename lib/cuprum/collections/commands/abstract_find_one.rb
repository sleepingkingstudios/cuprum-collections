# frozen_string_literal: true

require 'cuprum/parameter_validation'

require 'cuprum/collections/commands'
require 'cuprum/collections/errors/not_found'

module Cuprum::Collections::Commands
  # Abstract implementation of the FindOne command.
  module AbstractFindOne
    include Cuprum::ParameterValidation

    # @!method call(primary_key:, envelope: false)
    #   Queries the collection for the item with the given primary key.
    #
    #   The command will find and return the entity with the given primary key.
    #   If the entity is not found, the command will fail and return a NotFound
    #   error.
    #
    #   When the :envelope option is true, the command wraps the item in a Hash,
    #   using the singular name of the collection as the key.
    #
    #   @param envelope [Boolean] If true, wraps the result value in a Hash.
    #   @param primary_key [Object] The primary key of the requested item.
    #
    #   @return [Cuprum::Result<Hash{String, Object}>] a result with the
    #     requested item.
    validate :envelope, :boolean, optional: true
    validate :primary_key

    private

    def apply_query(primary_key:)
      key = primary_key_name

      query.where { |scope| { key => scope.equals(primary_key) } }.limit(1)
    end

    def handle_missing_item(item:, primary_key:)
      return if item

      error = Cuprum::Collections::Errors::NotFound.new(
        attribute_name:  primary_key_name,
        attribute_value: primary_key,
        collection_name:,
        primary_key:     true
      )
      Cuprum::Result.new(error:)
    end

    def process(primary_key:, envelope: false)
      query = apply_query(primary_key:)
      item  = query.to_a.first

      step { handle_missing_item(item:, primary_key:) }

      envelope ? wrap_item(item) : item
    end

    def wrap_item(item)
      { member_name => item }
    end
  end
end
