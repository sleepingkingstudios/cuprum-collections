# frozen_string_literal: true

require 'stannum/constraints/types/hash_with_indifferent_keys'

require 'cuprum/collections/basic/command'
require 'cuprum/collections/basic/commands'

module Cuprum::Collections::Basic::Commands
  # Command for generating a collection entity from an attributes hash.
  class BuildOne < Cuprum::Collections::Basic::Command
    # @!method call(attributes:, entity:)
    #   Builds a new entity with the given attributes.
    #
    #   @param attributes [Hash] The attributes and values to assign.
    #
    #   @return [Hash] the newly built entity.
    #
    #   @example Building an entity
    #     attributes = {
    #       'title'    => 'The Hobbit',
    #       'author'   => 'J.R.R. Tolkien',
    #       'series'   => nil,
    #       'category' => 'Science Fiction and Fantasy'
    #     }
    #     command    = BuildOne.new(collection_name: 'books', data: books)
    #     result     = command.call(attributes: attributes)
    #     result.value
    #     #=> {
    #       'title'    => 'The Silmarillion',
    #       'author'   => 'J.R.R. Tolkien',
    #       'series'   => nil,
    #       'category' => 'Science Fiction and Fantasy'
    #     }
    validate_parameters :call do
      keyword :attributes,
        Stannum::Constraints::Types::HashWithIndifferentKeys.new
    end

    private

    def process(attributes:)
      tools.hsh.convert_keys_to_strings(attributes)
    end
  end
end
