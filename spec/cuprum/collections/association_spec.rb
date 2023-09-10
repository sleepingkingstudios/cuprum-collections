# frozen_string_literal: true

require 'cuprum/collections/association'
require 'cuprum/collections/rspec/contracts/association_contracts'

require 'support/book'
require 'support/grimoire'
require 'support/scoped_book'

RSpec.describe Cuprum::Collections::Association do
  include Cuprum::Collections::RSpec::Contracts::AssociationContracts

  subject(:association) { described_class.new(**constructor_options) }

  let(:name)                { 'books' }
  let(:constructor_options) { { name: name } }

  include_contract 'should be a has association'

  include_contract 'should define cardinality'
end
