# frozen_string_literal: true

require 'support/commands'

module Spec::Support::Commands
  # @note Integration test for Basic::Collection.
  #
  # Also tests the Basic::Commands::FindOne command.
  class Show < Cuprum::Command
    def initialize(collection)
      super()

      @collection = collection
    end

    private

    attr_reader :collection

    def process(primary_key:)
      collection.find_one.call(primary_key:)
    end
  end
end
