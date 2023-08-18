# frozen_string_literal: true

require 'cuprum/collections/rspec'

module Cuprum::Collections::RSpec
  # Contract validating the behavior of an InsertOne command implementation.
  INSERT_ONE_COMMAND_CONTRACT = lambda do
    describe '#call' do
      let(:matching_data) { attributes }
      let(:expected_data) do
        defined?(super()) ? super() : matching_data
      end
      let(:primary_key_name) do
        defined?(super()) ? super() : 'id'
      end
      let(:primary_key_type) do
        defined?(super()) ? super() : Integer
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
        it 'should return a passing result' do
          expect(command.call(entity: entity))
            .to be_a_passing_result
            .with_value(be == expected_data)
        end

        it 'should append an item to the collection' do
          expect { command.call(entity: entity) }
            .to(
              change { query.reset.count }
              .by(1)
            )
        end

        it 'should add the entity to the collection' do
          expect { command.call(entity: entity) }
            .to change(scoped, :exists?)
            .to be true
        end

        it 'should set the attributes' do
          command.call(entity: entity)

          expect(scoped.to_a.first).to be == expected_data
        end
      end

      context 'when the item exists in the collection' do
        let(:data) { fixtures_data }
        let(:expected_error) do
          Cuprum::Collections::Errors::AlreadyExists.new(
            attribute_name:  primary_key_name,
            attribute_value: attributes.fetch(
              primary_key_name.to_s,
              attributes[primary_key_name.intern]
            ),
            collection_name: collection_name,
            primary_key:     true
          )
        end

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
    end
  end
end
