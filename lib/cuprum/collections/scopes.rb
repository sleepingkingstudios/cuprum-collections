# frozen_string_literal: true

require 'cuprum/collections'

module Cuprum::Collections
  # Namespace for scope functionality, which filters query data.
  module Scopes
    autoload :Criteria, 'cuprum/collections/scopes/criteria'
  end
end
