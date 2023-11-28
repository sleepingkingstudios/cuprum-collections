# frozen_string_literal: true

require 'stannum/constraints/presence'
require 'stannum/contracts/hash_contract'

require 'cuprum/collections/basic/collection'
require 'cuprum/collections/rspec/fixtures'

require 'support/commands/create'

RSpec.describe Spec::Support::Commands::Create do
  subject(:command) { described_class.new(collection) }

  let(:data) do
    Cuprum::Collections::RSpec::Fixtures::BOOKS_FIXTURES.dup
  end
  let(:collection_name) { 'books' }
  let(:collection_options) do
    {
      name: collection_name,
      data: data
    }
  end
  let(:collection) do
    Cuprum::Collections::Basic::Collection.new(**collection_options)
  end
  let(:query) do
    Cuprum::Collections::Basic::Query.new(collection.data)
  end

  describe '#call' do
    let(:primary_key) { data.count }
    let(:attributes)  { { 'id' => primary_key, 'title' => '' } }
    let(:contract)    { nil }
    let(:result) do
      command.call(attributes: attributes, contract: contract)
    end

    describe 'with contract: nil' do
      let(:expected_error) do
        Cuprum::Collections::Errors::MissingDefaultContract.new(
          entity_class: Hash
        )
      end

      it { expect(result).to be_a_failing_result.with_error(expected_error) }

      context 'when the collection has a non-matching default contract' do
        let(:default_contract) do
          Stannum::Contracts::HashContract.new(allow_extra_keys: true) do
            key 'title', Stannum::Constraints::Presence.new
          end
        end
        let(:collection_options) do
          super().merge(default_contract: default_contract)
        end
        let(:entity) { attributes }
        let(:expected_error) do
          Cuprum::Collections::Errors::FailedValidation.new(
            entity_class: Hash,
            errors:       default_contract.errors_for(entity)
          )
        end

        it { expect(result).to be_a_failing_result.with_error(expected_error) }
      end

      context 'when the collection has a matching default contract' do
        let(:default_contract) do
          Stannum::Contracts::HashContract.new(allow_extra_keys: true) do
            key 'title', Stannum::Constraints::Type.new(String)
          end
        end
        let(:collection_options) do
          super().merge(default_contract: default_contract)
        end
        let(:entity) { attributes }

        context 'when the entity already exists in the collection' do
          let(:primary_key) { 0 }
          let(:expected_error) do
            Cuprum::Collections::Errors::AlreadyExists.new(
              attribute_name:  'id',
              attribute_value: primary_key,
              collection_name: collection_name,
              primary_key:     true
            )
          end

          it 'should return a failing result' do
            expect(result).to be_a_failing_result.with_error(expected_error)
          end
        end

        context 'when the entity does not exist in the collection' do
          it { expect(result).to be_a_passing_result.with_value(entity) }

          it 'should add an item to the collection' do # rubocop:disable RSpec/ExampleLength
            expect do
              command.call(
                attributes: attributes,
                contract:   contract
              )
            end
              .to change { query.reset.count }
              .by(1)
          end

          it 'should insert the entity into the collection' do # rubocop:disable RSpec/ExampleLength
            command.call(
              attributes: attributes,
              contract:   contract
            )
            item = collection.find_one.call(primary_key: primary_key).value

            expect(item).to be == entity
          end
        end
      end
    end

    describe 'with contract: a non-matching contract' do
      let(:contract) do
        Stannum::Contracts::HashContract.new(allow_extra_keys: true) do
          key 'title', Stannum::Constraints::Presence.new
        end
      end
      let(:entity) { attributes }
      let(:expected_error) do
        Cuprum::Collections::Errors::FailedValidation.new(
          entity_class: Hash,
          errors:       contract.errors_for(entity)
        )
      end

      it { expect(result).to be_a_failing_result.with_error(expected_error) }
    end

    describe 'with contract: a matching contract' do
      let(:contract) do
        Stannum::Contracts::HashContract.new(allow_extra_keys: true) do
          key 'title', Stannum::Constraints::Type.new(String)
        end
      end
      let(:entity) { attributes }

      context 'when the entity already exists in the collection' do
        let(:primary_key) { 0 }
        let(:expected_error) do
          Cuprum::Collections::Errors::AlreadyExists.new(
            attribute_name:  'id',
            attribute_value: primary_key,
            collection_name: collection_name,
            primary_key:     true
          )
        end

        it 'should return a failing result' do
          expect(result).to be_a_failing_result.with_error(expected_error)
        end
      end

      context 'when the entity does not exist in the collection' do
        it { expect(result).to be_a_passing_result.with_value(entity) }

        it 'should add an item to the collection' do # rubocop:disable RSpec/ExampleLength
          expect do
            command.call(
              attributes: attributes,
              contract:   contract
            )
          end
            .to change { query.reset.count }
            .by(1)
        end

        it 'should insert the entity into the collection' do # rubocop:disable RSpec/ExampleLength
          command.call(
            attributes: attributes,
            contract:   contract
          )
          item = collection.find_one.call(primary_key: primary_key).value

          expect(item).to be == entity
        end
      end
    end
  end
end
