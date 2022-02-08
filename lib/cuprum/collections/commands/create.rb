# frozen_string_literal: true

require 'cuprum/collections/commands'

module Cuprum::Collections::Commands
  # Command for building, validating and inserting an entity into a collection.
  #
  # @example Creating An Entity
  #   command =
  #     Cuprum::Collections::Commands::Create.new(collection:)
  #     .new(collection: books_collection)
  #
  #   # With Invalid Attributes
  #   attributes = { 'title' => '' }
  #   result     = command.call(attributes: attributes)
  #   result.success?
  #   #=> false
  #   result.error
  #   #=> an instance of Cuprum::Collections::Errors::FailedValidation
  #   books_collection.query.count
  #   #=> 0
  #
  #   # With Valid Attributes
  #   attributes = { 'title' => 'Gideon the Ninth' }
  #   result     = command.call(attributes: attributes)
  #   result.success?
  #   #=> true
  #   result.value
  #   #=> a Book with title 'Gideon the Ninth'
  #   books_collection.query.count
  #   #=> 1
  class Create < Cuprum::Command
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

    def process(attributes:)
      entity = step { collection.build_one.call(attributes: attributes) }

      step { collection.validate_one.call(contract: contract, entity: entity) }

      collection.insert_one.call(entity: entity)
    end
  end
end
