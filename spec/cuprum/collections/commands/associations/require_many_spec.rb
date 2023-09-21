# frozen_string_literal: true

require 'cuprum/collections/associations/belongs_to'
require 'cuprum/collections/basic/repository'
require 'cuprum/collections/commands/associations/require_many'
require 'cuprum/collections/resource'

RSpec.describe Cuprum::Collections::Commands::Associations::RequireMany do
  subject(:command) do
    described_class.new(
      association: association,
      repository:  repository,
      resource:    resource
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
    let(:collection) do
      repository.find_or_create(
        name:           tools.str.pluralize(association.name),
        qualified_name: association.qualified_name
      )
    end
    let(:matching) { [] }
    let(:non_matching) do
      {
        'id'   => 3,
        'name' => 'Kim Harrison'
      }
    end

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
    end

    before(:example) do
      matching.each { |item| collection.insert_one.call(entity: item) }

      collection.insert_one.call(entity: non_matching)
    end

    it { expect(command).to be_callable.with_unlimited_arguments }

    describe 'with no arguments' do
      it 'should return a passing result' do
        expect(command.call)
          .to be_a_passing_result
          .with_value([])
      end
    end

    describe 'with one argument' do
      let(:entities) do
        [
          { 'id' => 0, 'author_id' => 0, 'title' => 'Gideon the Ninth' }
        ]
      end
      let(:expected_error) do
        Cuprum::Collections::Errors::Associations::NotFound.new(
          attribute_name:  association.query_key_name,
          attribute_value: [0],
          collection_name: association.name,
          primary_key:     association.primary_key_query?
        )
      end

      it 'should return a failing result' do
        expect(command.call(*entities))
          .to be_a_failing_result
          .with_error(expected_error)
      end

      context 'when there is one matching entity' do
        let(:matching) do
          [
            {
              'id'   => 0,
              'name' => 'Tammsyn Muir'
            }
          ]
        end

        it 'should return a passing result with the matching results' do
          expect(command.call(*entities))
            .to be_a_passing_result
            .with_value(matching)
        end
      end
    end

    describe 'with many arguments' do
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
      let(:expected_error) do
        Cuprum::Collections::Errors::Associations::NotFound.new(
          attribute_name:  association.query_key_name,
          attribute_value: [0, 1],
          collection_name: association.name,
          primary_key:     association.primary_key_query?
        )
      end

      it 'should return a failing result' do
        expect(command.call(*entities))
          .to be_a_failing_result
          .with_error(expected_error)
      end

      context 'when there is one matching entity' do
        let(:matching) do
          [
            {
              'id'   => 0,
              'name' => 'Tammsyn Muir'
            }
          ]
        end
        let(:expected_error) do
          Cuprum::Collections::Errors::Associations::NotFound.new(
            attribute_name:  association.query_key_name,
            attribute_value: [1],
            collection_name: association.name,
            primary_key:     association.primary_key_query?
          )
        end

        it 'should return a failing result' do
          expect(command.call(*entities))
            .to be_a_failing_result
            .with_error(expected_error)
        end
      end

      context 'when there are many matching entities' do
        let(:matching) do
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

        it 'should return a passing result with the matching results' do
          expect(command.call(*entities))
            .to be_a_passing_result
            .with_value(matching)
        end
      end
    end

    context 'when initialized with a singular resource' do
      let(:resource) do
        Cuprum::Collections::Resource.new(name: 'book', singular: true)
      end

      describe 'with no arguments' do
        it 'should return a passing result' do
          expect(command.call)
            .to be_a_passing_result
            .with_value(nil)
        end
      end

      describe 'with one argument' do
        let(:entities) do
          [
            { 'id' => 0, 'author_id' => 0, 'title' => 'Gideon the Ninth' }
          ]
        end
        let(:expected_error) do
          Cuprum::Collections::Errors::Associations::NotFound.new(
            attribute_name:  association.query_key_name,
            attribute_value: 0,
            collection_name: association.name,
            primary_key:     association.primary_key_query?
          )
        end

        it 'should return a failing result' do
          expect(command.call(*entities))
            .to be_a_failing_result
            .with_error(expected_error)
        end

        context 'when there is one matching entity' do
          let(:matching) do
            [
              {
                'id'   => 0,
                'name' => 'Tammsyn Muir'
              }
            ]
          end

          it 'should return a passing result with the matching results' do
            expect(command.call(*entities))
              .to be_a_passing_result
              .with_value(matching.first)
          end
        end
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
