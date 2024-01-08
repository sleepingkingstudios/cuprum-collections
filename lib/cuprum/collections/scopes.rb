# frozen_string_literal: true

require 'cuprum/collections'

module Cuprum::Collections
  # Namespace for scope functionality, which filters query data.
  module Scopes
    autoload :Base,          'cuprum/collections/scopes/base'
    autoload :Collection,    'cuprum/collections/scopes/collection'
    autoload :Criteria,      'cuprum/collections/scopes/criteria'
    autoload :CriteriaScope, 'cuprum/collections/scopes/criteria_scope'
  end
end
