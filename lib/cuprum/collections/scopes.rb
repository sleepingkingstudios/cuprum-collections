# frozen_string_literal: true

require 'cuprum/collections'

module Cuprum::Collections
  # Namespace for scope functionality, which filters query data.
  module Scopes
    autoload :All,              'cuprum/collections/scopes/all'
    autoload :AllScope,         'cuprum/collections/scopes/all_scope'
    autoload :Base,             'cuprum/collections/scopes/base'
    autoload :Builder,          'cuprum/collections/scopes/builder'
    autoload :Collection,       'cuprum/collections/scopes/collection'
    autoload :Composition,      'cuprum/collections/scopes/composition'
    autoload :Conjunction,      'cuprum/collections/scopes/conjunction'
    autoload :ConjunctionScope, 'cuprum/collections/scopes/conjunction_scope'
    autoload :Criteria,         'cuprum/collections/scopes/criteria'
    autoload :CriteriaScope,    'cuprum/collections/scopes/criteria_scope'
    autoload :Disjunction,      'cuprum/collections/scopes/disjunction'
    autoload :DisjunctionScope, 'cuprum/collections/scopes/disjunction_scope'
    autoload :None,             'cuprum/collections/scopes/none'
    autoload :NoneScope,        'cuprum/collections/scopes/none_scope'
  end
end
