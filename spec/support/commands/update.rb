# frozen_string_literal: true

require 'support/commands'

module Spec::Support::Commands
  # @note Integration test for Basic::Collection.
  #
  # Also tests the following commands:
  # - Basic::Commands::AssignOne
  # - Basic::Commands::FindOne
  # - Basic::Commands::ValidateOne
  # - Basic::Commands::UpdateOne
  class Update < Cuprum::Command
    def initialize(collection)
      super()

      @collection = collection
    end

    private

    attr_reader :collection

    def process(attributes:, primary_key:, contract: nil)
      entity = step { collection.find_one.call(primary_key: primary_key) }
      entity = step do
        collection.assign_one.call(attributes: attributes, entity: entity)
      end

      step { collection.validate_one.call(contract: contract, entity: entity) }

      step { collection.update_one.call(entity: entity) }

      entity
    end
  end
end
