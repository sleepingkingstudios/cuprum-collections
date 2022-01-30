# frozen_string_literal: true

require 'cuprum/collections/commands'
require 'cuprum/collections/errors/not_found'

module Cuprum::Collections::Commands
  # Abstract implementation of the FindOne command.
  #
  # Subclasses must define the #build_query method, which returns an empty
  # Query instance for that collection.
  module AbstractFindOne
    private

    def apply_query(primary_key:, scope:)
      key = primary_key_name

      (scope || build_query).where { { key => equals(primary_key) } }.limit(1)
    end

    def handle_missing_item(item:, primary_key:)
      return if item

      error = Cuprum::Collections::Errors::NotFound.new(
        attribute_name:  primary_key_name,
        attribute_value: primary_key,
        collection_name: collection_name,
        primary_key:     true
      )
      Cuprum::Result.new(error: error)
    end

    def process(envelope:, primary_key:, scope:)
      query = apply_query(primary_key: primary_key, scope: scope)
      item  = query.to_a.first

      step { handle_missing_item(item: item, primary_key: primary_key) }

      envelope ? wrap_item(item) : item
    end

    def wrap_item(item)
      { member_name => item }
    end
  end
end
