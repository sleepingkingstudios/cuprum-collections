# frozen_string_literal: true

require 'cuprum/collections/associations/has_one'
require 'cuprum/collections/rspec/deferred/association_examples'

require 'support/book'
require 'support/grimoire'
require 'support/scoped_book'

RSpec.describe Cuprum::Collections::Associations::HasOne do
  include Cuprum::Collections::RSpec::Deferred::AssociationExamples

  subject(:association) { described_class.new(**constructor_options) }

  let(:name)                { 'book' }
  let(:constructor_options) { { name: } }

  include_deferred 'should be a has Association'

  describe '#plural?' do
    it { expect(association.plural?).to be false }
  end

  describe '#singular?' do
    it { expect(association.singular?).to be true }
  end
end
