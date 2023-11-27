# frozen_string_literal: true

require 'stannum/constraints/presence'
require 'stannum/contracts/hash_contract'

require 'cuprum/collections/basic/collection'
require 'cuprum/collections/commands/create'

RSpec.describe Cuprum::Collections::Commands::Create do
  subject(:command) { described_class.new(**constructor_options) }

  shared_context 'when initialized with a contract' do
    let(:contract) do
      Stannum::Contracts::HashContract.new(allow_extra_keys: true) do
        key 'title', Stannum::Constraints::Presence.new
      end
    end
    let(:constructor_options) { super().merge(contract: contract) }
  end

  shared_context 'when the collection defines a default contract' do
    let(:contract) do
      Stannum::Contracts::HashContract.new(allow_extra_keys: true) do
        key 'author', Stannum::Constraints::Presence.new
      end
    end
    let(:collection_options) { super().merge(default_contract: contract) }
  end

  let(:collection) do
    Cuprum::Collections::Basic::Collection.new(
      name: 'books',
      data: [],
      **collection_options
    )
  end
  let(:collection_options)  { {} }
  let(:constructor_options) { { collection: collection } }

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:collection, :contract)
    end
  end

  describe '#call' do
    let(:expected_error) do
      Cuprum::Collections::Errors::MissingDefaultContract
        .new(entity_class: Hash)
    end

    it 'should define the method' do
      expect(command)
        .to be_callable
        .with(0).arguments
        .and_keywords(:attributes)
    end

    it 'should return a failing result' do
      expect(command.call(attributes: {}))
        .to be_a_failing_result
        .with_error(expected_error)
    end

    wrap_context 'when initialized with a contract' do
      describe 'with an invalid attributes Hash' do
        let(:attributes) { { 'title' => '' } }
        let(:expected_error) do
          errors = contract.errors_for(attributes)

          Cuprum::Collections::Errors::FailedValidation.new(
            entity_class: Hash,
            errors:       errors
          )
        end

        it 'should return a failing result' do
          expect(command.call(attributes: attributes))
            .to be_a_failing_result
            .with_error(expected_error)
        end

        it 'should not add an entity to the collection' do
          expect { command.call(attributes: attributes) }
            .not_to(change { collection.query.count })
        end
      end

      describe 'with a valid attributes Hash' do
        let(:attributes)     { { 'title' => 'Gideon the Ninth' } }
        let(:expected_value) { attributes }

        it 'should return a passing result' do
          expect(command.call(attributes: attributes))
            .to be_a_passing_result
            .with_value(expected_value)
        end

        it 'should add an entity to the collection' do
          expect { command.call(attributes: attributes) }
            .to(
              change { collection.query.count }
              .by(1)
            )
        end

        it 'should create the entity' do # rubocop:disable RSpec/ExampleLength
          command.call(attributes: attributes)

          expect(
            collection
            .query
            .where { { 'title' => 'Gideon the Ninth' } }
            .exists?
          ).to be true
        end
      end
    end

    wrap_context 'when the collection defines a default contract' do
      describe 'with an invalid attributes Hash' do
        let(:attributes) { { 'title' => '' } }
        let(:expected_error) do
          errors = contract.errors_for(attributes)

          Cuprum::Collections::Errors::FailedValidation.new(
            entity_class: Hash,
            errors:       errors
          )
        end

        it 'should return a failing result' do
          expect(command.call(attributes: attributes))
            .to be_a_failing_result
            .with_error(expected_error)
        end

        it 'should not add an entity to the collection' do
          expect { command.call(attributes: attributes) }
            .not_to(change { collection.query.count })
        end
      end

      describe 'with a valid attributes Hash' do
        let(:attributes)     { { 'author' => 'Tamsyn Muir' } }
        let(:expected_value) { attributes }

        it 'should return a passing result' do
          expect(command.call(attributes: attributes))
            .to be_a_passing_result
            .with_value(expected_value)
        end

        it 'should add an entity to the collection' do
          expect { command.call(attributes: attributes) }
            .to(
              change { collection.query.count }
              .by(1)
            )
        end

        it 'should create the entity' do # rubocop:disable RSpec/ExampleLength
          command.call(attributes: attributes)

          expect(
            collection
            .query
            .where { { 'author' => 'Tamsyn Muir' } }
            .exists?
          ).to be true
        end
      end
    end
  end

  describe '#collection' do
    include_examples 'should define reader', :collection, -> { collection }
  end

  describe '#contract' do
    include_examples 'should define reader', :contract, nil

    wrap_context 'when initialized with a contract' do
      it { expect(command.contract).to be contract }
    end
  end
end
