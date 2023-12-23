# frozen_string_literal: true

require 'cuprum/collections/basic'

module Cuprum::Collections::Basic
  # Namespace for basic scope functionality, which filters query data.
  module Scopes
    autoload :CriteriaScope, 'cuprum/collections/basic/scopes/criteria_scope'
  end
end
