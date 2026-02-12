# frozen_string_literal: true

require 'bronze'

module Bronze
  # Namespace for Relation-specific functionality.
  module Relations
    autoload :Cardinality, 'bronze/relations/cardinality'
    autoload :Options,     'bronze/relations/options'
    autoload :Parameters,  'bronze/relations/parameters'
    autoload :PrimaryKeys, 'bronze/relations/primary_keys'
    autoload :Scope,       'bronze/relations/scope'
  end
end
