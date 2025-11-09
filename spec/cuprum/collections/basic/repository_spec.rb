# frozen_string_literal: true

require 'cuprum/collections/basic/collection'
require 'cuprum/collections/basic/repository'
require 'cuprum/collections/rspec/fixtures'
require 'cuprum/collections/rspec/deferred/repository_examples'

require 'support/book'
require 'support/grimoire'
require 'support/scoped_book'

RSpec.describe Cuprum::Collections::Basic::Repository do
  include Cuprum::Collections::RSpec::Deferred::RepositoryExamples

  subject(:repository) { described_class.new(**constructor_options) }

  let(:constructor_options) { {} }

  define_method(:build_collection) do |**options|
    Cuprum::Collections::Basic::Collection.new(**options, data: [])
  end

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to respond_to(:new)
        .with(0).arguments
        .and_keywords(:data)
    end
  end

  include_deferred 'should be a Repository',
    collection_class:     Cuprum::Collections::Basic::Collection,
    entity_class:         Hash,
    find_by_entity_class: false

  describe '#create' do
    let(:collection_name)    { 'books' }
    let(:collection_options) { {} }
    let(:collection) do
      repository.create(name: collection_name, **collection_options)
    end

    it { expect(collection.count).to be 0 }

    describe 'with data: an Object' do
      let(:error_message) do
        'data must be an Array of Hashes'
      end

      it 'should raise an exception' do
        expect do
          repository.create(name: 'books', data: Object.new.freeze)
        end
          .to raise_error(ArgumentError, error_message)
      end
    end

    describe 'with data: an Array' do
      let(:data) do
        Cuprum::Collections::RSpec::Fixtures::BOOKS_FIXTURES.dup
      end
      let(:collection_options) { super().merge(data:) }

      it { expect(collection.count).to be data.size }
    end

    context 'when initialized with data: value' do
      let(:data) do
        { 'books' => Cuprum::Collections::RSpec::Fixtures::BOOKS_FIXTURES.dup }
      end
      let(:constructor_options) { super().merge(data:) }

      it { expect(collection.count).to be data['books'].size }
    end
  end

  describe '#find_or_create' do
    let(:collection_name)    { 'books' }
    let(:collection_options) { {} }
    let(:collection) do
      repository.find_or_create(
        name: collection_name,
        **collection_options
      )
    end

    before(:example) do
      allow(SleepingKingStudios::Tools::Toolbelt.instance.core_tools)
        .to receive(:deprecate)
    end

    it { expect(collection.count).to be 0 }

    describe 'with data: an Object' do
      let(:error_message) do
        'data must be an Array of Hashes'
      end

      it 'should raise an exception' do # rubocop:disable RSpec/ExampleLength
        expect do
          repository.find_or_create(
            name: 'books',
            data: Object.new.freeze
          )
        end
          .to raise_error(ArgumentError, error_message)
      end
    end

    describe 'with data: an Array' do
      let(:data) do
        Cuprum::Collections::RSpec::Fixtures::BOOKS_FIXTURES.dup
      end
      let(:collection_options) { super().merge(data:) }

      it { expect(collection.count).to be data.size }
    end

    context 'when initialized with data: value' do
      let(:data) do
        { 'books' => Cuprum::Collections::RSpec::Fixtures::BOOKS_FIXTURES.dup }
      end
      let(:constructor_options) { super().merge(data:) }

      it { expect(collection.count).to be data['books'].size }
    end
  end
end
