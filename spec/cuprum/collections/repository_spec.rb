# frozen_string_literal: true

require 'cuprum/collections/basic/collection'
require 'cuprum/collections/repository'
require 'cuprum/collections/rspec/repository_contract'

RSpec.describe Cuprum::Collections::Repository do
  include Cuprum::Collections::RSpec

  subject(:repository) { described_class.new }

  shared_context 'when the repository has many collections' do
    let(:books_collection) do
      instance_double(
        Cuprum::Collections::Basic::Collection,
        collection_name: 'books',
        qualified_name:  'sources/books'
      )
    end
    let(:authors_collection) do
      instance_double(
        Cuprum::Collections::Basic::Collection,
        collection_name: :authors,
        qualified_name:  'authors'
      )
    end
    let(:publishers_collection) do
      instance_double(
        Cuprum::Collections::Basic::Collection,
        collection_name: 'publishers',
        qualified_name:  'publishers'
      )
    end
    let(:collections) do
      {
        'sources/books' => books_collection,
        'authors'       => authors_collection,
        'publishers'    => publishers_collection
      }
    end

    before(:example) do
      repository <<
        books_collection <<
        authors_collection <<
        publishers_collection
    end
  end

  let(:example_collection) do
    instance_double(
      Cuprum::Collections::Basic::Collection,
      collection_name: 'widgets',
      qualified_name:  'scope/widgets'
    )
  end

  example_class 'Book', 'Hash'

  describe '::AbstractRepositoryError' do
    include_examples 'should define constant', :AbstractRepositoryError

    it { expect(described_class::AbstractRepositoryError).to be_a Class }

    it 'should inherit from StandardError' do
      expect(described_class::AbstractRepositoryError).to be < StandardError
    end
  end

  describe '::DuplicateCollectionError' do
    include_examples 'should define constant', :DuplicateCollectionError

    it { expect(described_class::DuplicateCollectionError).to be_a Class }

    it 'should inherit from StandardError' do
      expect(described_class::DuplicateCollectionError).to be < StandardError
    end
  end

  describe '::InvalidCollectionError' do
    include_examples 'should define constant', :InvalidCollectionError

    it { expect(described_class::InvalidCollectionError).to be_a Class }

    it 'should inherit from StandardError' do
      expect(described_class::InvalidCollectionError).to be < StandardError
    end
  end

  describe '::UndefinedCollectionError' do
    include_examples 'should define constant', :UndefinedCollectionError

    it { expect(described_class::UndefinedCollectionError).to be_a Class }

    it 'should inherit from StandardError' do
      expect(described_class::UndefinedCollectionError).to be < StandardError
    end
  end

  describe '.new' do
    it { expect(described_class).to respond_to(:new).with(0).arguments }
  end

  include_contract Cuprum::Collections::RSpec::RepositoryContract,
    abstract: true
end
