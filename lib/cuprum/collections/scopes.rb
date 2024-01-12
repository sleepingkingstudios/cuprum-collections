# frozen_string_literal: true

require 'cuprum/collections'

module Cuprum::Collections
  # Namespace for scope functionality, which filters query data.
  module Scopes
    autoload :Base,             'cuprum/collections/scopes/base'
    autoload :Collection,       'cuprum/collections/scopes/collection'
    autoload :ConjunctionScope, 'cuprum/collections/scopes/conjunction_scope'
    autoload :Criteria,         'cuprum/collections/scopes/criteria'
    autoload :CriteriaScope,    'cuprum/collections/scopes/criteria_scope'
    autoload :DisjunctionScope, 'cuprum/collections/scopes/disjunction_scope'
    autoload :NegationScope,    'cuprum/collections/scopes/negation_scope'
  end
end
