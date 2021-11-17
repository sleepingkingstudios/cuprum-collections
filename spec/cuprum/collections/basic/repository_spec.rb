# frozen_string_literal: true

require 'cuprum/collections/basic/collection'
require 'cuprum/collections/basic/repository'
require 'cuprum/collections/rspec/repository_contract'

RSpec.describe Cuprum::Collections::Basic::Repository do
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

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to respond_to(:new)
        .with(0).arguments
        .and_keywords(:data)
    end
  end

  include_contract Cuprum::Collections::RSpec::REPOSITORY_CONTRACT

  describe '#add' do
    describe 'with an invalid collection' do
      let(:error_class) do
        described_class::InvalidCollectionError
      end
      let(:error_message) do
        "#{collection.inspect} is not a valid collection"
      end
      let(:collection) do
        Struct.new(:collection_name).new
      end

      it 'should raise an exception' do
        expect { repository.add(collection) }
          .to raise_error(error_class, error_message)
      end
    end
  end

  describe '#build' do
    shared_examples 'should add the collection to the repository' do
      it 'should build a collection' do
        expect(build_collection).to be_a Cuprum::Collections::Basic::Collection
      end

      it 'should set the collection name' do
        expect(build_collection.collection_name).to be == collection_name.to_s
      end

      it { expect(build_collection.data).to be == [] }

      it 'should add the collection to the repository' do
        collection = build_collection

        expect(repository[collection_name.to_s]).to be collection
      end

      describe 'with data: value' do
        let(:data)    { [{ 'name' => 'Self-Sealing Stem Bolt' }] }
        let(:options) { super().merge(data: data) }

        it { expect(build_collection.data).to be == data }
      end

      context 'when initialized with data: value' do
        let(:collection_data) do
          {
            'widgets' => [
              { 'name' => 'Can of Headlight Fluid' }
            ]
          }
        end
        let(:constructor_options) do
          super().merge(data: collection_data)
        end

        it 'should initialize the collection with data' do
          expect(build_collection.data)
            .to be == collection_data[collection_name.to_s]
        end

        describe 'with data: value' do
          let(:data)    { [{ 'name' => 'Self-Sealing Stem Bolt' }] }
          let(:options) { super().merge(data: data) }

          it { expect(build_collection.data).to be == data }
        end
      end

      describe 'with options' do
        let(:options) do
          super().merge(
            primary_key_name: :uuid,
            primary_key_type: String
          )
        end

        it { expect(build_collection.primary_key_name).to be == :uuid }

        it { expect(build_collection.primary_key_type).to be String }
      end
    end

    let(:collection_name) { 'widgets' }
    let(:options)         { {} }

    def build_collection
      repository.build(
        collection_name: collection_name,
        **options
      )
    end

    it 'should define the method' do
      expect(repository)
        .to respond_to(:build)
        .with_keywords(:collection_name)
        .and_any_keywords
    end

    describe 'with collection_name: nil' do
      let(:collection_name) { nil }
      let(:error_message) do
        "collection name can't be blank"
      end

      it 'should raise an exception' do
        expect { repository.build(collection_name: collection_name) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with collection_name: an object' do
      let(:collection_name) { Object.new.freeze }
      let(:error_message) do
        'collection name must be a String or Symbol'
      end

      it 'should raise an exception' do
        expect { repository.build(collection_name: collection_name) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with collection_name: an empty string' do
      let(:collection_name) { '' }
      let(:error_message) do
        "collection name can't be blank"
      end

      it 'should raise an exception' do
        expect { repository.build(collection_name: collection_name) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with collection_name: a string' do
      let(:collection_name) { 'widgets' }

      include_examples 'should add the collection to the repository'
    end

    describe 'with collection_name: a symbol' do
      let(:collection_name) { :widgets }

      include_examples 'should add the collection to the repository'
    end

    describe 'with data: an object' do
      let(:data) { Object.new }
      let(:error_message) do
        'data must be an Array of Hashes'
      end

      it 'should raise an exception' do
        expect do
          repository.build(collection_name: collection_name, data: data)
        end
          .to raise_error ArgumentError, error_message
      end
    end
  end
end
