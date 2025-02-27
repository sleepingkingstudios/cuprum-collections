# frozen_string_literal: true

require 'cuprum/collections/collection'
require 'cuprum/collections/rspec/deferred/collection_examples'

require 'support/book'
require 'support/grimoire'
require 'support/scoped_book'

RSpec.describe Cuprum::Collections::Collection do
  include Cuprum::Collections::RSpec::Deferred::CollectionExamples

  subject(:collection) do
    described_class.new(**constructor_options)
  end

  let(:name)                { 'books' }
  let(:constructor_options) { { name: } }

  describe '::AbstractCollectionError' do
    include_examples 'should define constant', :AbstractCollectionError

    it { expect(described_class::AbstractCollectionError).to be_a Class }

    it 'should inherit from StandardError' do
      expect(described_class::AbstractCollectionError).to be < StandardError
    end
  end

  describe '.new' do
    let(:expected_keywords) do
      %i[
        collection_name
        entity_class
        member_name
        name
        qualified_name
        scope
        singular_name
      ]
    end

    def call_method(**parameters)
      described_class.new(**parameters)
    end

    it 'should define the constructor' do
      expect(described_class.new(name: 'books'))
        .to respond_to(:initialize, true)
        .with(0).arguments
        .and_keywords(*expected_keywords)
        .and_any_keywords
    end

    include_deferred 'should validate the Relation parameters'
  end

  include_deferred 'should be a Collection', abstract: true
end
