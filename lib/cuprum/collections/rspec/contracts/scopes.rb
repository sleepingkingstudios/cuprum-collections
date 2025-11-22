# frozen_string_literal: true

require 'cuprum/collections/rspec/contracts'

module Cuprum::Collections::RSpec::Contracts
  # Namespace for RSpec contracts validating the behavior of scopes.
  #
  # @deprecated 0.6.0
  module Scopes
    autoload :CriteriaContracts,
      'cuprum/collections/rspec/contracts/scopes/criteria_contracts'
    autoload :LogicalContracts,
      'cuprum/collections/rspec/contracts/scopes/logical_contracts'
  end
end
