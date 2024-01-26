# frozen_string_literal: true

require 'stannum/constraints/boolean'

require 'cuprum/collections/basic/command'
require 'cuprum/collections/basic/commands'
require 'cuprum/collections/commands/abstract_find_one'

module Cuprum::Collections::Basic::Commands
  # Command for finding one collection item by primary key.
  class FindOne < Cuprum::Collections::Basic::Command
    include Cuprum::Collections::Commands::AbstractFindOne

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
    validate_parameters :call do
      keyword :envelope,    Stannum::Constraints::Boolean.new, default: true
      keyword :primary_key, Object
    end

    private

    def process(primary_key:, envelope: false)
      step { validate_primary_key(primary_key) }

      super
    end
  end
end
