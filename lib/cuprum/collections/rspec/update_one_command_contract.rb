# frozen_string_literal: true

require 'cuprum/collections/rspec'
require 'cuprum/collections/rspec/fixtures'

module Cuprum::Collections::RSpec
  # Contract validating the behavior of an UpdateOne command implementation.
  UPDATE_ONE_COMMAND_CONTRACT = lambda do
    describe '#call' do
      let(:mapped_data) do
        defined?(super()) ? super() : data
      end
      let(:matching_data) { attributes }
      let(:expected_data) do
        defined?(super()) ? super() : matching_data
      end
      let(:primary_key_name) do
        defined?(super()) ? super() : :id
      end
      let(:scoped) do
        key    = primary_key_name
        value  = entity[primary_key_name.to_s]

        query.where { { key => value } }
      end

      it 'should validate the :entity keyword' do
        expect(command)
          .to validate_parameter(:call, :entity)
          .using_constraint(entity_type)
      end

      context 'when the item does not exist in the collection' do
        let(:expected_error) do
          Cuprum::Collections::Errors::NotFound.new(
            collection_name:    collection_name,
            primary_key_name:   primary_key_name,
            primary_key_values: attributes[primary_key_name]
          )
        end
        let(:matching_data) { mapped_data.first }

        it 'should return a failing result' do
          expect(command.call(entity: entity))
            .to be_a_failing_result
            .with_error(expected_error)
        end

        it 'should not append an item to the collection' do
          expect { command.call(entity: entity) }
            .not_to(change { query.reset.count })
        end
      end

      context 'when the item exists in the collection' do
        let(:data) { Cuprum::Collections::RSpec::BOOKS_FIXTURES.dup }
        let(:matching_data) do
          mapped_data.first.merge(super())
        end

        it 'should return a passing result' do
          expect(command.call(entity: entity))
            .to be_a_passing_result
            .with_value(be == expected_data)
        end

        it 'should not append an item to the collection' do
          expect { command.call(entity: entity) }
            .not_to(change { query.reset.count })
        end

        it 'should set the attributes' do
          command.call(entity: entity)

          expect(scoped.to_a.first).to be == expected_data
        end
      end
    end
  end
end
