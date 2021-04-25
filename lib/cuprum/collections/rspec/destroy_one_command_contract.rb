# frozen_string_literal: true

require 'cuprum/collections/rspec'
require 'cuprum/collections/rspec/fixtures'

module Cuprum::Collections::RSpec
  # Contract validating the behavior of a FindOne command implementation.
  DESTROY_ONE_COMMAND_CONTRACT = lambda do
    describe '#call' do
      let(:mapped_data) do
        defined?(super()) ? super() : data
      end
      let(:primary_key_name) { defined?(super()) ? super() : :id }
      let(:primary_key_type) { defined?(super()) ? super() : Integer }
      let(:invalid_primary_key_value) do
        defined?(super()) ? super() : 100
      end
      let(:valid_primary_key_value) do
        defined?(super()) ? super() : 0
      end

      it 'should validate the :primary_key keyword' do
        expect(command)
          .to validate_parameter(:call, :primary_key)
          .using_constraint(primary_key_type)
      end

      describe 'with an invalid primary key' do
        let(:primary_key) { invalid_primary_key_value }
        let(:expected_error) do
          Cuprum::Collections::Errors::NotFound.new(
            collection_name:    command.collection_name,
            primary_key_name:   primary_key_name,
            primary_key_values: primary_key
          )
        end

        it 'should return a failing result' do
          expect(command.call(primary_key: primary_key))
            .to be_a_failing_result
            .with_error(expected_error)
        end

        it 'should not remove an entity from the collection' do
          expect { command.call(primary_key: primary_key) }
            .not_to change(mapped_data, :count)
        end
      end

      context 'when the collection has many items' do
        let(:data) { Cuprum::Collections::RSpec::BOOKS_FIXTURES.dup }
        let(:matching_data) do
          mapped_data.find { |item| item[primary_key_name.to_s] == primary_key }
        end
        let!(:expected_data) do
          defined?(super()) ? super() : matching_data
        end

        describe 'with an invalid primary key' do
          let(:primary_key) { invalid_primary_key_value }
          let(:expected_error) do
            Cuprum::Collections::Errors::NotFound.new(
              collection_name:    command.collection_name,
              primary_key_name:   primary_key_name,
              primary_key_values: primary_key
            )
          end

          it 'should return a failing result' do
            expect(command.call(primary_key: primary_key))
              .to be_a_failing_result
              .with_error(expected_error)
          end

          it 'should not remove an entity from the collection' do
            expect { command.call(primary_key: primary_key) }
              .not_to change(mapped_data, :count)
          end
        end

        describe 'with a valid primary key' do
          let(:primary_key) { valid_primary_key_value }

          it 'should return a passing result' do
            expect(command.call(primary_key: primary_key))
              .to be_a_passing_result
              .with_value(expected_data)
          end

          it 'should remove an entity from the collection' do
            expect { command.call(primary_key: primary_key) }
              .to change(mapped_data, :count)
              .by(-1)
          end

          it 'should remove the entity from the collection' do
            command.call(primary_key: primary_key)

            expect(mapped_data).not_to include(
              satisfy { |item| item[primary_key_name.to_s] == primary_key }
            )
          end
        end
      end
    end
  end
end
