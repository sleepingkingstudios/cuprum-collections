# frozen_string_literal: true

require 'cuprum/collections/collection'
require 'cuprum/collections/rspec/collection_contract'

RSpec.describe Cuprum::Collections::Collection do
  subject(:collection) do
    described_class.new(**constructor_options)
  end

  let(:collection_name)     { 'books' }
  let(:constructor_options) { { collection_name: collection_name } }

  describe '::AbstractCollectionError' do
    include_examples 'should define constant', :AbstractCollectionError

    it { expect(described_class::AbstractCollectionError).to be_a Class }

    it 'should inherit from StandardError' do
      expect(described_class::AbstractCollectionError).to be < StandardError
    end
  end

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to respond_to(:new)
        .with(0).arguments
        .and_keywords(:collection_name)
        .and_any_keywords
    end
  end

  example_class 'Book'
  example_class 'Grimoire',         'Book'
  example_class 'Spec::ScopedBook', 'Book'

  include_contract Cuprum::Collections::RSpec::CollectionContract,
    abstract: true
end
