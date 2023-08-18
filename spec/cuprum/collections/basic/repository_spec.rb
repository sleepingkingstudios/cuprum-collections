# frozen_string_literal: true

require 'cuprum/collections/basic/collection'
require 'cuprum/collections/basic/repository'
require 'cuprum/collections/rspec/fixtures'
require 'cuprum/collections/rspec/repository_contract'

RSpec.describe Cuprum::Collections::Basic::Repository do
  include Cuprum::Collections::RSpec

  subject(:repository) { described_class.new(**constructor_options) }

  shared_context 'when the repository has many collections' do
    let(:books_collection) do
      Cuprum::Collections::Basic::Collection.new(
        collection_name: 'books',
        data:            []
      )
    end
    let(:authors_collection) do
      Cuprum::Collections::Basic::Collection.new(
        collection_name: 'authors',
        data:            []
      )
    end
    let(:publishers_collection) do
      Cuprum::Collections::Basic::Collection.new(
        collection_name: 'publishers',
        data:            []
      )
    end
    let(:collections) do
      {
        'books'      => books_collection,
        'authors'    => authors_collection,
        'publishers' => publishers_collection
      }
    end

    before(:example) do
      repository <<
        books_collection <<
        authors_collection <<
        publishers_collection
    end
  end

  let(:constructor_options) { {} }
  let(:example_collection) do
    Cuprum::Collections::Basic::Collection.new(
      collection_name: 'widgets',
      data:            []
    )
  end

  example_class 'Book',             'Hash'
  example_class 'Grimoire',         'Book'
  example_class 'Spec::ScopedBook', 'Book'

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to respond_to(:new)
        .with(0).arguments
        .and_keywords(:data)
    end
  end

  include_contract Cuprum::Collections::RSpec::RepositoryContract,
    collection_class: Cuprum::Collections::Basic::Collection,
    entity_class:     Hash

  describe '#create' do
    let(:collection_name)    { 'books' }
    let(:collection_options) { {} }
    let(:collection) do
      repository.create(collection_name: collection_name, **collection_options)
    end

    it { expect(collection.count).to be 0 }

    describe 'with data: an Object' do
      let(:error_message) do
        'data must be an Array of Hashes'
      end

      it 'should raise an exception' do
        expect do
          repository.create(collection_name: 'books', data: Object.new.freeze)
        end
          .to raise_error(ArgumentError, error_message)
      end
    end

    describe 'with data: an Array' do
      let(:data) do
        Cuprum::Collections::RSpec::BOOKS_FIXTURES
      end
      let(:collection_options) { super().merge(data: data) }

      it { expect(collection.count).to be data.size }
    end

    context 'when initialized with data: value' do
      let(:data) do
        { 'books' => Cuprum::Collections::RSpec::BOOKS_FIXTURES }
      end
      let(:constructor_options) { super().merge(data: data) }

      it { expect(collection.count).to be data['books'].size }
    end
  end

  describe '#find_or_create' do
    let(:collection_name)    { 'books' }
    let(:collection_options) { {} }
    let(:collection) do
      repository.find_or_create(
        collection_name: collection_name,
        **collection_options
      )
    end

    it { expect(collection.count).to be 0 }

    describe 'with data: an Object' do
      let(:error_message) do
        'data must be an Array of Hashes'
      end

      it 'should raise an exception' do # rubocop:disable RSpec/ExampleLength
        expect do
          repository.find_or_create(
            collection_name: 'books',
            data:            Object.new.freeze
          )
        end
          .to raise_error(ArgumentError, error_message)
      end
    end

    describe 'with data: an Array' do
      let(:data) do
        Cuprum::Collections::RSpec::BOOKS_FIXTURES
      end
      let(:collection_options) { super().merge(data: data) }

      it { expect(collection.count).to be data.size }
    end

    context 'when initialized with data: value' do
      let(:data) do
        { 'books' => Cuprum::Collections::RSpec::BOOKS_FIXTURES }
      end
      let(:constructor_options) { super().merge(data: data) }

      it { expect(collection.count).to be data['books'].size }
    end
  end
end
