# frozen_string_literal: true

require 'bronze/basic'

module Bronze::Basic
  # Namespace for basic scope functionality, which filters query data.
  module Scopes
    autoload :AllScope,         'bronze/basic/scopes/all_scope'
    autoload :Base,             'bronze/basic/scopes/base'
    autoload :Builder,          'bronze/basic/scopes/builder'
    autoload :ConjunctionScope, 'bronze/basic/scopes/conjunction_scope'
    autoload :CriteriaScope,    'bronze/basic/scopes/criteria_scope'
    autoload :DisjunctionScope, 'bronze/basic/scopes/disjunction_scope'
    autoload :NoneScope,        'bronze/basic/scopes/none_scope'
  end
end
