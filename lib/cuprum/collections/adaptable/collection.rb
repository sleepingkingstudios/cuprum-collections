# frozen_string_literal: true

require 'cuprum/collections/adaptable'

module Cuprum::Collections::Adaptable
  # Mixin for defining adaptable collections.
  module Collection
    # @param adapter [Cuprum::Collections::Adapter] the collection adapter.
    def initialize(adapter:, **parameters)
      super(default_entity_class: adapter.entity_class, **parameters)

      @adapter = adapter
    end

    # @return [Cuprum::Collections::Adapter] the collection adapter.
    attr_reader :adapter
  end
end
