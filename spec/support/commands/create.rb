# frozen_string_literal: true

require 'support/commands'

module Spec::Support::Commands
  # @note Integration test for Basic::Collection.
  #
  # Also tests the following commands:
  # - Basic::Commands::BuildOne
  # - Basic::Commands::ValidateOne
  # - Basic::Commands::InsertOne
  class Create < Cuprum::Command
    def initialize(collection)
      super()

      @collection = collection
    end

    private

    attr_reader :collection

    def process(attributes:, contract: nil)
      entity = step { collection.build_one.call(attributes: attributes) }

      step { collection.validate_one.call(contract: contract, entity: entity) }

      step { collection.insert_one.call(entity: entity) }
    end
  end
end
