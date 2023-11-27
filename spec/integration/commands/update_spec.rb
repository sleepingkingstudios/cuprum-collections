# frozen_string_literal: true

require 'stannum/constraints/presence'
require 'stannum/contracts/hash_contract'

require 'cuprum/collections/basic/collection'
require 'cuprum/collections/rspec/fixtures'

require 'support/commands/update'

RSpec.describe Spec::Support::Commands::Update do
  subject(:command) { described_class.new(collection) }

  let(:collection_name) { 'books' }
  let(:data)            { Cuprum::Collections::RSpec::BOOKS_FIXTURES.dup }
  let(:collection_options) do
    {
      name: collection_name,
      data: data
    }
  end
  let(:collection) do
    Cuprum::Collections::Basic::Collection.new(**collection_options)
  end

  describe '#call' do
    let(:attributes)  { { 'title' => '' } }
    let(:primary_key) { 0 }
    let(:contract)    { nil }
    let(:result) do
      command.call(
        attributes:  attributes,
        contract:    contract,
        primary_key: primary_key
      )
    end

    describe 'with an invalid primary key' do
      let(:primary_key) { 100 }
      let(:expected_error) do
        Cuprum::Collections::Errors::NotFound.new(
          attribute_name:  'id',
          attribute_value: primary_key,
          collection_name: collection_name,
          primary_key:     true
        )
      end

      it { expect(result).to be_a_failing_result.with_error(expected_error) }
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
        let(:entity) do
          data
            .find { |item| item['id'] == primary_key }
            .merge(attributes)
        end
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
        let(:entity) do
          data
            .find { |item| item['id'] == primary_key }
            .merge(attributes)
        end

        it { expect(result).to be_a_passing_result.with_value(entity) }

        it 'should update the collection item' do # rubocop:disable RSpec/ExampleLength
          command.call(
            attributes:  attributes,
            contract:    contract,
            primary_key: primary_key
          )
          item = collection.find_one.call(primary_key: primary_key).value

          expect(item).to be == entity
        end
      end
    end

    describe 'with contract: a non-matching contract' do
      let(:contract) do
        Stannum::Contracts::HashContract.new(allow_extra_keys: true) do
          key 'title', Stannum::Constraints::Presence.new
        end
      end
      let(:entity) do
        data
          .find { |item| item['id'] == primary_key }
          .merge(attributes)
      end
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
      let(:entity) do
        data
          .find { |item| item['id'] == primary_key }
          .merge(attributes)
      end

      it { expect(result).to be_a_passing_result.with_value(entity) }

      it 'should update the collection item' do # rubocop:disable RSpec/ExampleLength
        command.call(
          attributes:  attributes,
          contract:    contract,
          primary_key: primary_key
        )
        item = collection.find_one.call(primary_key: primary_key).value

        expect(item).to be == entity
      end
    end
  end
end
