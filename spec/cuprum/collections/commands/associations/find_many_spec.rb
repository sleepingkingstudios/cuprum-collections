# frozen_string_literal: true

require 'cuprum/collections/associations'
require 'cuprum/collections/associations/belongs_to'
require 'cuprum/collections/basic/repository'
require 'cuprum/collections/commands/associations/find_many'
require 'cuprum/collections/resource'

RSpec.describe Cuprum::Collections::Commands::Associations::FindMany do
  subject(:command) do
    described_class.new(
      association:,
      repository:,
      resource:
    )
  end

  let(:association) { Cuprum::Collections::Association.new(name: 'books') }
  let(:repository) do
    Cuprum::Collections::Basic::Repository.new.tap do |repository|
      repository.create(qualified_name: association.qualified_name)
    end
  end
  let(:resource) { Cuprum::Collections::Resource.new(name: 'authors') }

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:association, :repository, :resource)
    end
  end

  describe '#association' do
    include_examples 'should define reader', :association, -> { association }
  end

  describe '#call' do
    shared_examples 'should find the plural association for one entity' do
      context 'when there is are no matching entities' do
        it 'should return a passing result with no results' do
          expect(command.call(**params))
            .to be_a_passing_result
            .with_value([])
        end
      end

      context 'when there is one matching entity' do
        let(:matching) { values[0..0] }

        it 'should return a passing result with the matching results' do
          expect(command.call(**params))
            .to be_a_passing_result
            .with_value(matching)
        end
      end

      context 'when there are multiple matching entities' do
        let(:matching) { values[0..2] }

        it 'should return a passing result with the matching results' do
          expect(command.call(**params))
            .to be_a_passing_result
            .with_value(matching)
        end
      end
    end

    shared_examples 'should find the plural association for many entities' do
      context 'when there is are no matching entities' do
        it 'should return a passing result with no results' do
          expect(command.call(**params))
            .to be_a_passing_result
            .with_value([])
        end
      end

      context 'when there are multiple matching entities' do
        let(:matching) { values }

        it 'should return a passing result with the matching results' do
          expect(command.call(**params))
            .to be_a_passing_result
            .with_value(matching)
        end
      end
    end

    shared_examples 'should find the singular association for one entity' do
      context 'when there is no matching entity' do
        it 'should return a passing result with no results' do
          expect(command.call(**params))
            .to be_a_passing_result
            .with_value(nil)
        end
      end

      context 'when there is one matching entity' do
        let(:matching) { values[0..0] }

        it 'should return a passing result with the matching results' do
          expect(command.call(**params))
            .to be_a_passing_result
            .with_value(matching.first)
        end
      end
    end

    shared_examples 'should find the singular association for many entities' do
      context 'when there is are no matching entities' do
        it 'should return a passing result with no results' do
          expect(command.call(**params))
            .to be_a_passing_result
            .with_value([])
        end
      end

      context 'when there are multiple matching entities' do
        let(:matching) { values }

        it 'should return a passing result with the matching results' do
          expect(command.call(**params))
            .to be_a_passing_result
            .with_value(matching)
        end
      end
    end

    let(:collection) do
      repository.find(qualified_name: association.qualified_name)
    end
    let(:non_matching) do
      {
        'author_id' => 4,
        'title'     => 'Dead Witch Walking'
      }
    end
    let(:entities) do
      [
        { 'id' => 0, 'name' => 'Tammsyn Muir' },
        { 'id' => 1, 'name' => 'Ursula K. LeGuin' },
        { 'id' => 2, 'name' => 'Seanan McGuire' }
      ]
    end
    let(:values) do
      [
        {
          'id'        => 0,
          'author_id' => 0,
          'title'     => 'Gideon the Ninth'
        },
        {
          'id'        => 1,
          'author_id' => 0,
          'title'     => 'Harrow the Ninth'
        },
        {
          'id'        => 2,
          'author_id' => 0,
          'title'     => 'Nona the Ninth'
        },
        {
          'id'        => 4,
          'author_id' => 1,
          'title'     => 'The Word For World Is Forest'
        }
      ]
    end
    let(:inverse_key_name) do
      association.with_inverse(resource).inverse_key_name
    end
    let(:params)   { {} }
    let(:matching) { [] }

    before(:example) do
      matching.each { |item| collection.insert_one.call(entity: item) }

      collection.insert_one.call(entity: non_matching)
    end

    it 'should define the method' do
      expect(command)
        .to be_callable
        .with(0).arguments
        .and_keywords(:entities, :entity, :key, :keys)
    end

    describe 'with no arguments' do
      let(:error_message) do
        'missing keyword :entity, :entities, :key, or :keys'
      end

      it 'should raise an exception' do
        expect { command.call(**params) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with invalid keywords' do
      let(:params) { { key: nil, custom: 'value', other: 'value' } }
      let(:error_message) do
        'invalid keywords :custom, :other'
      end

      it 'should raise an exception' do
        expect { command.call(**params) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with ambiguous keywords' do
      let(:params) { { key: nil, keys: [] } }
      let(:error_message) do
        'ambiguous keywords :key, :keys - must provide exactly one parameter'
      end

      it 'should raise an exception' do
        expect { command.call(**params) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with entity: nil' do
      let(:params) { { entity: nil } }

      it 'should return a passing result with no results' do
        expect(command.call(**params))
          .to be_a_passing_result
          .with_value([])
      end
    end

    describe 'with entity: an Object' do
      let(:params) { { entity: entities.first } }

      include_examples 'should find the plural association for one entity'
    end

    describe 'with entities: an empty Array' do
      let(:params) { { entities: [] } }

      it 'should return a passing result with no results' do
        expect(command.call(**params))
          .to be_a_passing_result
          .with_value([])
      end
    end

    describe 'with entities: an Array of Objects' do
      let(:params) { { entities: } }

      include_examples 'should find the plural association for many entities'
    end

    describe 'with key: nil' do
      let(:params) { { key: nil } }

      it 'should return a passing result with no results' do
        expect(command.call(**params))
          .to be_a_passing_result
          .with_value([])
      end
    end

    describe 'with key: an Integer' do
      let(:params) { { key: entities.first[inverse_key_name] } }

      include_examples 'should find the plural association for one entity'
    end

    describe 'with keys: an empty Array' do
      let(:params) { { keys: [] } }

      it 'should return a passing result with no results' do
        expect(command.call(**params))
          .to be_a_passing_result
          .with_value([])
      end
    end

    describe 'with keys: an Array of Integers' do
      let(:params) do
        { keys: entities.map { |entity| entity[inverse_key_name] } }
      end

      include_examples 'should find the plural association for many entities'
    end

    context 'when initialized with a belongs_to association' do
      let(:association) do
        Cuprum::Collections::Associations::BelongsTo.new(name: 'author')
      end
      let(:resource) { Cuprum::Collections::Resource.new(name: 'books') }
      let(:non_matching) do
        {
          'id'   => 3,
          'name' => 'Kim Harrison'
        }
      end
      let(:entities) do
        [
          { 'id' => 0, 'author_id' => 0, 'title' => 'Gideon the Ninth' },
          { 'id' => 1, 'author_id' => 0, 'title' => 'Harrow the Ninth' },
          {
            'id'        => 2,
            'author_id' => 1,
            'title'     => 'The Word For World Is Forest'
          }
        ]
      end
      let(:values) do
        [
          {
            'id'   => 0,
            'name' => 'Tammsyn Muir'
          },
          {
            'id'   => 1,
            'name' => 'Ursula K. LeGuin'
          }
        ]
      end

      describe 'with entity: an Object' do
        let(:params) { { entity: entities.first } }

        include_examples 'should find the singular association for one entity'
      end

      describe 'with entities: an Array of Objects' do
        let(:params) { { entities: } }

        include_examples \
          'should find the singular association for many entities'
      end

      describe 'with key: an Integer' do
        let(:params) { { key: entities.first[inverse_key_name] } }

        include_examples 'should find the singular association for one entity'
      end

      describe 'with keys: an Array of Integers' do
        let(:params) do
          { keys: entities.map { |entity| entity[inverse_key_name] } }
        end

        include_examples \
          'should find the singular association for many entities'
      end

      context 'when initialized with a singular resource' do
        let(:resource) do
          Cuprum::Collections::Resource.new(name: 'book', singular: true)
        end

        describe 'with entity: an Object' do
          let(:params) { { entity: entities.first } }

          include_examples 'should find the singular association for one entity'
        end

        describe 'with key: an Integer' do
          let(:params) { { key: entities.first[inverse_key_name] } }

          include_examples 'should find the singular association for one entity'
        end
      end
    end

    context 'when initialized with a singular association' do
      let(:association) do
        Cuprum::Collections::Association.new(name: 'agent', singular: true)
      end
      let(:non_matching) do
        {
          'author_id' => 3,
          'name'      => 'Jane C. Agent'
        }
      end
      let(:values) do
        [
          {
            'id'        => 0,
            'author_id' => 0,
            'title'     => 'Jane A. Agent'
          },
          {
            'id'        => 1,
            'author_id' => 1,
            'title'     => 'John B. Agent'
          }
        ]
      end

      describe 'with entity: an Object' do
        let(:params) { { entity: entities.first } }

        include_examples 'should find the singular association for one entity'
      end

      describe 'with entities: an Array of Objects' do
        let(:params) { { entities: } }

        include_examples \
          'should find the singular association for many entities'
      end

      describe 'with key: an Integer' do
        let(:params) { { key: entities.first[inverse_key_name] } }

        include_examples 'should find the singular association for one entity'
      end

      describe 'with keys: an Array of Integers' do
        let(:params) do
          { keys: entities.map { |entity| entity[inverse_key_name] } }
        end

        include_examples \
          'should find the singular association for many entities'
      end

      context 'when initialized with a singular resource' do
        let(:resource) do
          Cuprum::Collections::Resource.new(name: 'author', singular: true)
        end

        describe 'with key: an Integer' do
          let(:params) { { key: entities.first[inverse_key_name] } }

          include_examples 'should find the singular association for one entity'
        end

        describe 'with entity: an Object' do
          let(:params) { { entity: entities.first } }

          include_examples 'should find the singular association for one entity'
        end
      end
    end

    context 'when initialized with a singular resource' do
      let(:resource) do
        Cuprum::Collections::Resource.new(name: 'author', singular: true)
      end

      describe 'with entity: an Object' do
        let(:params) { { entity: entities.first } }

        include_examples 'should find the plural association for one entity'
      end

      describe 'with key: an Integer' do
        let(:params) { { key: entities.first[inverse_key_name] } }

        include_examples 'should find the plural association for one entity'
      end
    end

    context 'when the collection does not exist' do
      let(:params) { { key: entities.first[inverse_key_name] } }
      let(:error_message) do
        'repository does not define collection "books"'
      end

      before(:example) do
        repository.remove(qualified_name: association.qualified_name)
      end

      it 'should raise an exception' do
        expect { command.call(**params) }.to raise_error(
          Cuprum::Collections::Repository::UndefinedCollectionError,
          error_message
        )
      end
    end
  end

  describe '#repository' do
    include_examples 'should define reader', :repository, -> { repository }
  end

  describe '#resource' do
    include_examples 'should define reader', :resource, -> { resource }
  end
end
