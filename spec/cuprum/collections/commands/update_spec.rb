# frozen_string_literal: true

require 'stannum/constraints/presence'
require 'stannum/contracts/hash_contract'

require 'cuprum/collections/basic/collection'
require 'cuprum/collections/commands/update'

RSpec.describe Cuprum::Collections::Commands::Update do
  subject(:command) { described_class.new(**constructor_options) }

  shared_context 'when initialized with a contract' do
    let(:contract) do
      Stannum::Contracts::HashContract.new(allow_extra_keys: true) do
        key 'series', Stannum::Constraints::Presence.new
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
      collection_name: 'books',
      data:            [],
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
    let(:entity) do
      collection
        .build_one
        .call(
          attributes: {
            'title'  => 'Gideon the Ninth',
            'author' => 'Tamsyn Muir',
            'series' => 'The Locked Tomb'
          }
        )
        .value
    end

    def reload_attributes
      collection
        .find_matching
        .call { { 'title' => 'Gideon the Ninth' } }
        .value
        .first
    end

    before(:example) do
      collection.insert_one.call(entity: entity)
    end

    it 'should define the method' do
      expect(command)
        .to be_callable
        .with(0).arguments
        .and_keywords(:attributes, :entity)
    end

    it 'should return a failing result' do
      expect(command.call(attributes: {}, entity: entity))
        .to be_a_failing_result
        .with_error(expected_error)
    end

    wrap_context 'when initialized with a contract' do
      describe 'with an invalid attributes Hash' do
        let(:attributes) { { 'series' => '' } }
        let(:expected_error) do
          errors = contract.errors_for(attributes)

          Cuprum::Collections::Errors::FailedValidation.new(
            entity_class: Hash,
            errors:       errors
          )
        end

        it 'should return a failing result' do
          expect(command.call(attributes: attributes, entity: entity))
            .to be_a_failing_result
            .with_error(expected_error)
        end

        it 'should not update the attributes' do
          expect { command.call(attributes: attributes, entity: entity) }
            .not_to(change { reload_attributes })
        end
      end

      describe 'with a valid attributes Hash' do
        let(:attributes)     { { 'author' => '' } }
        let(:expected_value) { entity.merge(attributes) }

        it 'should return a passing result' do
          expect(command.call(attributes: attributes, entity: entity))
            .to be_a_passing_result
            .with_value(expected_value)
        end

        it 'should update the attributes' do
          expect { command.call(attributes: attributes, entity: entity) }
            .to(
              change { reload_attributes }
              .to be == expected_value
            )
        end
      end
    end

    wrap_context 'when the collection defines a default contract' do
      describe 'with an invalid attributes Hash' do
        let(:attributes) { { 'author' => '' } }
        let(:expected_error) do
          errors = contract.errors_for(attributes)

          Cuprum::Collections::Errors::FailedValidation.new(
            entity_class: Hash,
            errors:       errors
          )
        end

        it 'should return a failing result' do
          expect(command.call(attributes: attributes, entity: entity))
            .to be_a_failing_result
            .with_error(expected_error)
        end

        it 'should not update the attributes' do
          expect { command.call(attributes: attributes, entity: entity) }
            .not_to(change { reload_attributes })
        end
      end

      describe 'with a valid attributes Hash' do
        let(:attributes)     { { 'series' => '' } }
        let(:expected_value) { entity.merge(attributes) }

        it 'should return a passing result' do
          expect(command.call(attributes: attributes, entity: entity))
            .to be_a_passing_result
            .with_value(expected_value)
        end

        it 'should update the attributes' do
          expect { command.call(attributes: attributes, entity: entity) }
            .to(
              change { reload_attributes }
              .to be == expected_value
            )
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
