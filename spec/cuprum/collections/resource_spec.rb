# frozen_string_literal: true

require 'cuprum/collections/resource'
require 'cuprum/collections/rspec/contracts/relation_contracts'

require 'support/book'
require 'support/grimoire'
require 'support/scoped_book'

RSpec.describe Cuprum::Collections::Resource do
  include Cuprum::Collections::RSpec::Contracts::RelationContracts

  subject(:resource) { described_class.new(**constructor_options) }

  let(:name)                { 'books' }
  let(:constructor_options) { { name: } }

  include_contract 'should be a relation',
    cardinality: true

  include_contract 'should define primary keys'

  include_contract 'should define cardinality'
end
