# frozen_string_literal: true

require 'cuprum/collections/rspec'

module Cuprum::Collections::RSpec
  # Namespace for RSpec contract objects.
  module Contracts
    autoload :QueryContracts,
      'cuprum/collections/rspec/contracts/query_contracts'
    autoload :RepositoryContracts,
      'cuprum/collections/rspec/contracts/repository_contracts'
    autoload :ScopeContracts,
      'cuprum/collections/rspec/contracts/scope_contracts'
    autoload :Scopes,
      'cuprum/collections/rspec/contracts/scopes'
  end
end
