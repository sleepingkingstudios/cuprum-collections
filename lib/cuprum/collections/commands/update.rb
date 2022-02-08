# frozen_string_literal: true

require 'cuprum/collections/commands'

module Cuprum::Collections::Commands
  # Command for assigning, validating and updating an entity in a collection.
  #
  # @example Updating An Entity
  #   command =
  #     Cuprum::Collections::Commands::Create.new(collection:)
  #     .new(collection: books_collection)
  #   entity  =
  #     books_collection
  #     .find_matching { { 'title' => 'Gideon the Ninth' } }
  #     .value
  #     .first
  #
  #   # With Invalid Attributes
  #   attributes = { 'author' => '' }
  #   result     = command.call(attributes: attributes)
  #   result.success?
  #   #=> false
  #   result.error
  #   #=> an instance of Cuprum::Collections::Errors::FailedValidation
  #   books_collection
  #     .find_matching { { 'title' => 'Gideon the Ninth' } }
  #     .value
  #     .first['author']
  #   #=> 'Tamsyn Muir'
  #
  #   # With Valid Attributes
  #   attributes = { 'series' => 'The Locked Tomb' }
  #   result     = command.call(attributes: attributes)
  #   result.success?
  #   #=> true
  #   result.value
  #   #=> an instance of Book with title 'Gideon the Ninth' and series
  #       'The Locked Tomb'
  #   books_collection
  #     .find_matching { { 'title' => 'Gideon the Ninth' } }
  #     .value
  #     .first['series']
  #   #=> 'The Locked Tomb'
  class Update < Cuprum::Command
    # @param collection [Object] The collection used to store the entity.
    # @param contract [Stannum::Constraint] The constraint used to validate the
    #   entity. If not given, defaults to the default contract for the
    #   collection.
    def initialize(collection:, contract: nil)
      super()

      @collection = collection
      @contract   = contract
    end

    # @return [Object] the collection used to store the entity.
    attr_reader :collection

    # @return [Stannum::Constraint] the constraint used to validate the entity.
    attr_reader :contract

    private

    def process(attributes:, entity:)
      entity = step do
        collection.assign_one.call(attributes: attributes, entity: entity)
      end

      step { collection.validate_one.call(entity: entity, contract: contract) }

      step { collection.update_one.call(entity: entity) }
    end
  end
end
