# frozen_string_literal: true

require 'cuprum/collections/basic'

module Cuprum::Collections::Basic
  # Namespace for basic scope functionality, which filters query data.
  module Scopes
    autoload :Base,
      'cuprum/collections/basic/scopes/base'
    autoload :ConjunctionScope,
      'cuprum/collections/basic/scopes/conjunction_scope'
    autoload :CriteriaScope,
      'cuprum/collections/basic/scopes/criteria_scope'
    autoload :DisjunctionScope,
      'cuprum/collections/basic/scopes/disjunction_scope'
    autoload :NegationScope,
      'cuprum/collections/basic/scopes/negation_scope'
  end
end
