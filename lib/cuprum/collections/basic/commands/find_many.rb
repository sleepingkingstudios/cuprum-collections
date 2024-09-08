# frozen_string_literal: true

require 'stannum/constraints/boolean'

require 'cuprum/collections/basic/command'
require 'cuprum/collections/basic/commands'
require 'cuprum/collections/commands/abstract_find_many'

module Cuprum::Collections::Basic::Commands
  # Command for finding multiple collection items by primary key.
  class FindMany < Cuprum::Collections::Basic::Command
    include Cuprum::Collections::Commands::AbstractFindMany

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

    def items_with_primary_keys(items:)
      # :nocov:
      items.to_h { |item| [item[primary_key_name.to_s], item] }
      # :nocov:
    end
  end
end
