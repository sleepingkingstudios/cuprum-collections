# frozen_string_literal: true

require 'cuprum/collections/reference'

module Cuprum::Collections::Reference
  # Abstract base class for reference collection commands.
  class Command < Cuprum::Collections::Command
    # @param data [Array<Hash>] The current data in the collection.
    def initialize(data)
      super()

      @data = data
    end

    # @return [Array<Hash>] the current data in the collection.
    attr_reader :data
  end
end
