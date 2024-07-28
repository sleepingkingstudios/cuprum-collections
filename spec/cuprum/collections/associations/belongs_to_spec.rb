# frozen_string_literal: true

require 'cuprum/collections/associations/belongs_to'
require 'cuprum/collections/rspec/contracts/association_contracts'

require 'support/book'
require 'support/grimoire'
require 'support/scoped_book'

RSpec.describe Cuprum::Collections::Associations::BelongsTo do
  include Cuprum::Collections::RSpec::Contracts::AssociationContracts

  subject(:association) { described_class.new(**constructor_options) }

  let(:name)                { 'books' }
  let(:constructor_options) { { name: } }

  include_contract 'should be a belongs to association'

  describe '#plural?' do
    it { expect(association.plural?).to be false }
  end

  describe '#singular?' do
    it { expect(association.singular?).to be true }
  end
end
