# frozen_string_literal: true

require 'cuprum/collections/rspec'

module Cuprum::Collections::RSpec
  # Namespace for RSpec contract objects.
  module Contracts
    autoload :RelationContracts,
      'cuprum/collections/rspec/contracts/relation_contracts'
  end
end
