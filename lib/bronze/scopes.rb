# frozen_string_literal: true

require 'bronze'

module Bronze
  # Namespace for scope functionality, which filters query data.
  module Scopes
    autoload :All,              'bronze/scopes/all'
    autoload :AllScope,         'bronze/scopes/all_scope'
    autoload :Base,             'bronze/scopes/base'
    autoload :Builder,          'bronze/scopes/builder'
    autoload :Building,         'bronze/scopes/building'
    autoload :Composition,      'bronze/scopes/composition'
    autoload :Conjunction,      'bronze/scopes/conjunction'
    autoload :ConjunctionScope, 'bronze/scopes/conjunction_scope'
    autoload :Container,        'bronze/scopes/container'
    autoload :Criteria,         'bronze/scopes/criteria'
    autoload :CriteriaScope,    'bronze/scopes/criteria_scope'
    autoload :Disjunction,      'bronze/scopes/disjunction'
    autoload :DisjunctionScope, 'bronze/scopes/disjunction_scope'
    autoload :None,             'bronze/scopes/none'
    autoload :NoneScope,        'bronze/scopes/none_scope'
  end
end
