# frozen_string_literal: true

require 'stannum/constraints/types/hash_with_indifferent_keys'
require 'stannum/constraints/types/hash_with_string_keys'

require 'cuprum/collections/basic/command'
require 'cuprum/collections/basic/commands'

module Cuprum::Collections::Basic::Commands
  # Command for assigning attributes to a collection entity.
  class AssignOne < Cuprum::Collections::Basic::Command
    # @!method call(attributes:, entity:)
    #   Assigns the given attributes to the entity.
    #
    #   Any attributes on the entity that are not part of the given attributes
    #   hash are unchanged.
    #
    #   @param attributes [Hash] The attributes and values to update.
    #   @param entity [Hash] The collection entity to update.
    #
    #   @return [Hash] a copy of the entity, merged with the given attributes.
    #
    #   @example Assigning attributes
    #     entity = {
    #       'title'    => 'The Hobbit',
    #       'author'   => 'J.R.R. Tolkien',
    #       'series'   => nil,
    #       'category' => 'Science Fiction and Fantasy'
    #     }
    #     attributes = { title: 'The Silmarillion' }
    #     command = AssignOne.new(collection_name: 'books', data: books)
    #     command.call(attributes: attributes, entity: entity)
    #     #=> {
    #       'title'    => 'The Silmarillion',
    #       'author'   => 'J.R.R. Tolkien',
    #       'series'   => nil,
    #       'category' => 'Science Fiction and Fantasy'
    #     }
    validate :attributes
    validate :entity

    private

    def process(attributes:, entity:)
      attributes = tools.hsh.convert_keys_to_strings(attributes)

      entity.merge(attributes)
    end
  end
end
