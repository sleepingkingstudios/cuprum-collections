# frozen_string_literal: true

require 'cuprum/collections/rspec'

module Cuprum::Collections::RSpec
  # Namespace for RSpec contract objects.
  module Contracts
    autoload :AssociationContracts,
      'cuprum/collections/rspec/contracts/association_contracts'
    autoload :Basic,
      'cuprum/collections/rspec/contracts/basic'
    autoload :CollectionContracts,
      'cuprum/collections/rspec/contracts/collection_contracts'
    autoload :CommandContracts,
      'cuprum/collections/rspec/contracts/command_contracts'
    autoload :QueryContracts,
      'cuprum/collections/rspec/contracts/query_contracts'
    autoload :RelationContracts,
      'cuprum/collections/rspec/contracts/relation_contracts'
    autoload :RepositoryContracts,
      'cuprum/collections/rspec/contracts/repository_contracts'
  end
end
