# frozen_string_literal: true

require 'cuprum/collections/rspec/contracts'

module Cuprum::Collections::RSpec::Contracts
  # Namespace for RSpec contracts validating the behavior of scopes.
  module Scopes
    autoload :CriteriaContracts,
      'cuprum/collections/rspec/contracts/scopes/criteria_contracts'
  end
end
