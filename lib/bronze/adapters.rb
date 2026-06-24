# frozen_string_literal: true

require 'bronze'

module Bronze
  # Namespace for adapter implementations.
  #
  # @see Bronze::Adapter.
  module Adapters
    autoload :DataAdapter,   'bronze/adapters/data_adapter'
    autoload :EntityAdapter, 'bronze/adapters/entity_adapter'
    autoload :HashAdapter,   'bronze/adapters/hash_adapter'
  end
end
