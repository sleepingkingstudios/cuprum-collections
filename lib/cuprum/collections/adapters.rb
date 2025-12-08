# frozen_string_literal: true

require 'cuprum/collections'

module Cuprum::Collections
  # Namespace for adapter implementations.
  #
  # @see Cuprum::Collections::Adapter.
  module Adapters
    autoload :DataAdapter,   'cuprum/collections/adapters/data_adapter'
    autoload :EntityAdapter, 'cuprum/collections/adapters/entity_adapter'
    autoload :HashAdapter,   'cuprum/collections/adapters/hash_adapter'
  end
end
