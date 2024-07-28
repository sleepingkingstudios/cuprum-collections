# frozen_string_literal: true

require 'cuprum/collections/commands'
require 'cuprum/collections/commands/query_command'
require 'cuprum/collections/errors/not_found'

module Cuprum::Collections::Commands
  # Abstract implementation of the FindOne command.
  module AbstractFindOne
    include Cuprum::Collections::Commands::QueryCommand

    private

    def apply_query(primary_key:)
      key = primary_key_name

      query.where { { key => equals(primary_key) } }.limit(1)
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

    def process(envelope:, primary_key:)
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
