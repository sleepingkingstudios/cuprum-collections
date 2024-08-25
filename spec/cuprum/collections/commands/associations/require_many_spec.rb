# frozen_string_literal: true

require 'cuprum/collections/associations/belongs_to'
require 'cuprum/collections/basic/repository'
require 'cuprum/collections/commands/associations/require_many'
require 'cuprum/collections/resource'

RSpec.describe Cuprum::Collections::Commands::Associations::RequireMany do
  subject(:command) do
    described_class.new(
      association:,
      repository:,
      resource:
    )
  end

  let(:association) do
    Cuprum::Collections::Associations::BelongsTo.new(name: 'author')
  end
  let(:repository) { Cuprum::Collections::Basic::Repository.new }
  let(:resource)   { Cuprum::Collections::Resource.new(name: 'books') }

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
    shared_examples 'should require the association for one entity' do
      context 'when there is no matching entity' do
        let(:expected_error) do
          Cuprum::Collections::Errors::NotFound.new(
            attribute_name:  association.query_key_name,
            attribute_value: 0,
            collection_name: association.name,
            primary_key:     association.primary_key_query?
          )
        end

        it 'should return a failing result' do
          expect(command.call(**params))
            .to be_a_failing_result
            .with_error(expected_error)
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

    shared_examples 'should require the association for many entities' do
      context 'when there are no matching entities' do
        let(:expected_error) do
          Cuprum::Collections::Errors::NotFound.new(
            attribute_name:  association.query_key_name,
            attribute_value: [0, 1],
            collection_name: association.name,
            primary_key:     association.primary_key_query?
          )
        end

        it 'should return a failing result' do
          expect(command.call(**params))
            .to be_a_failing_result
            .with_error(expected_error)
        end
      end

      context 'when there are some matching entities' do
        let(:matching) { values[0..0] }
        let(:expected_error) do
          Cuprum::Collections::Errors::NotFound.new(
            attribute_name:  association.query_key_name,
            attribute_value: [1],
            collection_name: association.name,
            primary_key:     association.primary_key_query?
          )
        end

        it 'should return a failing result' do
          expect(command.call(**params))
            .to be_a_failing_result
            .with_error(expected_error)
        end
      end

      context 'when there are many matching entities' do
        let(:matching) { values }

        it 'should return a passing result with the matching results' do
          expect(command.call(**params))
            .to be_a_passing_result
            .with_value(matching)
        end
      end
    end

    let(:collection) do
      repository.find_or_create(
        name:           tools.str.pluralize(association.name),
        qualified_name: association.qualified_name
      )
    end
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
    let(:inverse_key_name) do
      association.with_inverse(resource).inverse_key_name
    end
    let(:params)   { {} }
    let(:matching) { [] }

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
    end

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
          .with_value(nil)
      end
    end

    describe 'with entity: an Object' do
      let(:params) { { entity: entities.first } }

      include_examples 'should require the association for one entity'
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

      include_examples 'should require the association for many entities'
    end

    describe 'with key: nil' do
      let(:params) { { key: nil } }

      it 'should return a passing result with no results' do
        expect(command.call(**params))
          .to be_a_passing_result
          .with_value(nil)
      end
    end

    describe 'with key: an Integer' do
      let(:params) { { key: entities.first[inverse_key_name] } }

      include_examples 'should require the association for one entity'
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

      include_examples 'should require the association for many entities'
    end

    context 'when initialized with a singular resource' do
      let(:resource) do
        Cuprum::Collections::Resource.new(name: 'book', singular: true)
      end

      describe 'with entity: an Object' do
        let(:params) { { entity: entities.first } }

        include_examples 'should require the association for one entity'
      end

      describe 'with key: an Integer' do
        let(:params) { { key: entities.first[inverse_key_name] } }

        include_examples 'should require the association for one entity'
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
