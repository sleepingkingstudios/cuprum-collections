# frozen_string_literal: true

require 'cuprum/collections/associations/has_many'
require 'cuprum/collections/rspec/contracts/association_contracts'

require 'support/book'
require 'support/grimoire'
require 'support/scoped_book'

RSpec.describe Cuprum::Collections::Associations::HasMany do
  include Cuprum::Collections::RSpec::Contracts::AssociationContracts

  subject(:association) { described_class.new(**constructor_options) }

  let(:name)                { 'books' }
  let(:constructor_options) { { name: } }

  include_contract 'should be a has association'

  describe '#plural?' do
    it { expect(association.plural?).to be true }
  end

  describe '#singular?' do
    it { expect(association.singular?).to be false }
  end
end
