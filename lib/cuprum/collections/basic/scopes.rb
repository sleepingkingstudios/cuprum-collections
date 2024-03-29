# frozen_string_literal: true

require 'cuprum/collections/basic'

module Cuprum::Collections::Basic
  # Namespace for basic scope functionality, which filters query data.
  module Scopes
    autoload :AllScope,
      'cuprum/collections/basic/scopes/all_scope'
    autoload :Base,
      'cuprum/collections/basic/scopes/base'
    autoload :Builder,
      'cuprum/collections/basic/scopes/builder'
    autoload :ConjunctionScope,
      'cuprum/collections/basic/scopes/conjunction_scope'
    autoload :CriteriaScope,
      'cuprum/collections/basic/scopes/criteria_scope'
    autoload :DisjunctionScope,
      'cuprum/collections/basic/scopes/disjunction_scope'
    autoload :NoneScope,
      'cuprum/collections/basic/scopes/none_scope'
  end
end
