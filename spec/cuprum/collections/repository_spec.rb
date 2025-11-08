# frozen_string_literal: true

require 'cuprum/collections/basic/collection'
require 'cuprum/collections/repository'
require 'cuprum/collections/rspec/deferred/repository_examples'

require 'support/book'

RSpec.describe Cuprum::Collections::Repository do
  include Cuprum::Collections::RSpec::Deferred::RepositoryExamples

  subject(:repository) { described_class.new }

  define_method(:build_collection) do |**options|
    name           = options.fetch(:name)
    qualified_name = options.fetch(:qualified_name, name)

    instance_double(
      Cuprum::Collections::Basic::Collection,
      name:,
      qualified_name:
    )
  end

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

  include_deferred 'should be a Repository', abstract: true
end
