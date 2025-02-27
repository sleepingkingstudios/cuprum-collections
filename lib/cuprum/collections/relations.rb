# frozen_string_literal: true

require 'cuprum/collections'

module Cuprum::Collections
  # Namespace for Relation-specific functionality.
  module Relations
    autoload :Cardinality, 'cuprum/collections/relations/cardinality'
    autoload :Options,     'cuprum/collections/relations/options'
    autoload :Parameters,  'cuprum/collections/relations/parameters'
    autoload :PrimaryKeys, 'cuprum/collections/relations/primary_keys'
    autoload :Scope,       'cuprum/collections/relations/scope'
  end
end
