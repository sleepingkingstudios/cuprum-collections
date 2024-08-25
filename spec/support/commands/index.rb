# frozen_string_literal: true

require 'support/commands'

module Spec::Support::Commands
  # @note Integration test for Basic::Collection.
  #
  # Also tests the following commands:
  # - Basic::Commands::FindMatching
  class Index < Cuprum::Command
    def initialize(collection)
      super()

      @collection = collection
    end

    private

    attr_reader :collection

    def process(envelope: false, **parameters)
      step do
        collection.find_matching.call(
          envelope:,
          **parameters
        )
      end
    end
  end
end
