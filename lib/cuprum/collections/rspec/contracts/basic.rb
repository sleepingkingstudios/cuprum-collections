# frozen_string_literal: true

require 'cuprum/collections/rspec/contracts'

module Cuprum::Collections::RSpec::Contracts
  # Namespace for RSpec contract objects for Basic collections.
  module Basic
    autoload :CommandContracts,
      'cuprum/collections/rspec/contracts/basic/command_contracts'
  end
end
