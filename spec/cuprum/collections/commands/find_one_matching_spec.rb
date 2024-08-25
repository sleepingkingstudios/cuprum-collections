# frozen_string_literal: true

require 'cuprum/collections/basic/collection'
require 'cuprum/collections/commands/find_one_matching'
require 'cuprum/collections/rspec/fixtures'

RSpec.describe Cuprum::Collections::Commands::FindOneMatching do
  subject(:command) { described_class.new(collection:) }

  let(:data) { [] }
  let(:name) { 'books' }
  let(:collection) do
    Cuprum::Collections::Basic::Collection.new(
      name:,
      data:
    )
  end

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:collection)
    end
  end

  describe '#call' do
    it 'should define the method' do
      expect(command)
        .to be_callable
        .with(0).arguments
        .and_keywords(:attributes)
        .and_a_block
    end

    describe 'with attributes: a Hash that does not match any entities' do
      let(:attributes) { { 'author' => 'Jules Verne' } }
      let(:expected_error) do
        Cuprum::Collections::Errors::NotFound.new(
          attributes:,
          collection_name: name
        )
      end

      it 'should return a failing result' do
        expect(command.call(attributes:))
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end

    describe 'with a block that does not match any entities' do
      let(:query) do
        Cuprum::Collections::Basic::Query
          .new(data)
          .where { { 'author' => 'Jules Verne' } }
      end
      let(:expected_error) do
        Cuprum::Collections::Errors::NotFound.new(
          collection_name: name,
          query:
        )
      end

      it 'should return a failing result' do
        expect(command.call { { 'author' => 'Jules Verne' } })
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end

    context 'when there are many entities' do
      let(:data) { Cuprum::Collections::RSpec::Fixtures::BOOKS_FIXTURES.dup }

      describe 'with attributes: a Hash that does not match any entities' do
        let(:attributes) { { 'author' => 'Jules Verne' } }
        let(:expected_error) do
          Cuprum::Collections::Errors::NotFound.new(
            attributes:,
            collection_name: name
          )
        end

        it 'should return a failing result' do
          expect(command.call(attributes:))
            .to be_a_failing_result
            .with_error(expected_error)
        end
      end

      describe 'with attributes: a Hash that matches one entity' do
        let(:attributes) { { 'title' => 'The Word for World is Forest' } }
        let(:matching_entity) do
          collection
            .find_matching
            .call { { 'title' => 'The Word for World is Forest' } }
            .value
            .first
        end

        it 'should return a passing result' do
          expect(command.call(attributes:))
            .to be_a_passing_result
            .with_value(matching_entity)
        end
      end

      describe 'with attributes: a Hash that matches multiple entities' do
        let(:attributes) { { 'author' => 'Ursula K. LeGuin' } }
        let(:expected_error) do
          Cuprum::Collections::Errors::NotUnique.new(
            attributes:,
            collection_name: name
          )
        end

        it 'should return a failing result' do
          expect(command.call(attributes:))
            .to be_a_failing_result
            .with_error(expected_error)
        end
      end

      describe 'with a block that does not match any entities' do
        let(:block) { -> { { 'author' => 'Jules Verne' } } }
        let(:query) do
          Cuprum::Collections::Basic::Query
            .new(data)
            .where { { 'author' => 'Jules Verne' } }
        end
        let(:expected_error) do
          Cuprum::Collections::Errors::NotFound.new(
            collection_name: name,
            query:
          )
        end

        it 'should return a failing result' do
          expect(command.call(&block))
            .to be_a_failing_result
            .with_error(expected_error)
        end
      end

      describe 'with a block that matches one entity' do
        let(:block) do
          lambda do |scope|
            {
              'author'       => 'Ursula K. LeGuin',
              'series'       => 'Earthsea',
              'published_at' => scope.greater_than('1972-01-01')
            }
          end
        end
        let(:matching_entity) do
          collection
            .find_matching
            .call { { 'title' => 'The Farthest Shore' } }
            .value
            .first
        end

        it 'should return a passing result' do
          expect(command.call(&block))
            .to be_a_passing_result
            .with_value(matching_entity)
        end
      end

      describe 'with a block that matches multiple entities' do
        let(:block) do
          lambda do |scope|
            {
              'author'       => 'Ursula K. LeGuin',
              'series'       => 'Earthsea',
              'published_at' => scope.greater_than('1970-01-01')
            }
          end
        end
        let(:query) do
          block = self.block

          Cuprum::Collections::Basic::Query.new(data).where(&block)
        end
        let(:expected_error) do
          Cuprum::Collections::Errors::NotUnique.new(
            collection_name: name,
            query:
          )
        end

        it 'should return a failing result' do
          expect(command.call(&block))
            .to be_a_failing_result
            .with_error(expected_error)
        end
      end
    end
  end

  describe '#collection' do
    include_examples 'should define reader', :collection, -> { collection }
  end
end
