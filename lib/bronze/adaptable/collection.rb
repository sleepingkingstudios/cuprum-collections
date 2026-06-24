# frozen_string_literal: true

require 'bronze/adaptable'

module Bronze::Adaptable
  # Mixin for defining adaptable collections.
  module Collection
    # @param adapter [Bronze::Adapter] the collection adapter.
    def initialize(adapter:, **parameters)
      super(default_entity_class: adapter.entity_class, **parameters)

      @adapter = adapter
    end

    # @return [Bronze::Adapter] the collection adapter.
    attr_reader :adapter
  end
end
