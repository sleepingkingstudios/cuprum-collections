# frozen_string_literal: true

require 'cuprum/collections/rspec/deferred/command_examples'
require 'cuprum/collections/rspec/deferred/commands'

module Cuprum::Collections::RSpec::Deferred::Commands
  # Namespace for deferred example groups for validating DestroyOne commands.
  module DestroyOneExamples
    include RSpec::SleepingKingStudios::Deferred::Provider

    deferred_examples 'should implement the DestroyOne command' do
      describe '#call' do
        include Cuprum::Collections::RSpec::Deferred::CommandExamples

        let(:query) { collection.query }
        let(:mapped_data) do
          defined?(super()) ? super() : data
        end
        let(:invalid_primary_key_value) do
          defined?(super()) ? super() : 100
        end
        let(:valid_primary_key_value) do
          defined?(super()) ? super() : 0
        end

        def call_command
          command.call(primary_key:)
        end

        include_deferred 'should validate the primary key parameter'

        describe 'with an invalid primary key' do
          let(:primary_key) { invalid_primary_key_value }
          let(:expected_error) do
            Cuprum::Collections::Errors::NotFound.new(
              attribute_name:  collection.primary_key_name,
              attribute_value: primary_key,
              collection_name: collection.name,
              primary_key:     true
            )
          end

          it 'should return a failing result' do
            expect(command.call(primary_key:))
              .to be_a_failing_result
              .with_error(expected_error)
          end

          it 'should not remove an entity from the collection' do
            expect { command.call(primary_key:) }
              .not_to(change { query.reset.count })
          end
        end

        context 'when the collection has many items' do
          let(:data) { fixtures_data }
          let(:matching_data) do
            mapped_data.find do |item|
              item[collection.primary_key_name.to_s] == primary_key
            end
          end
          let!(:expected_data) do
            defined?(super()) ? super() : matching_data
          end

          describe 'with an invalid primary key' do
            let(:primary_key) { invalid_primary_key_value }
            let(:expected_error) do
              Cuprum::Collections::Errors::NotFound.new(
                attribute_name:  collection.primary_key_name,
                attribute_value: primary_key,
                collection_name: collection.name,
                primary_key:     true
              )
            end

            it 'should return a failing result' do
              expect(command.call(primary_key:))
                .to be_a_failing_result
                .with_error(expected_error)
            end

            it 'should not remove an entity from the collection' do
              expect { command.call(primary_key:) }
                .not_to(change { query.reset.count })
            end
          end

          describe 'with a valid primary key' do
            let(:primary_key) { valid_primary_key_value }

            it 'should return a passing result' do
              expect(command.call(primary_key:))
                .to be_a_passing_result
                .with_value(expected_data)
            end

            it 'should remove an entity from the collection' do
              expect { command.call(primary_key:) }
                .to(
                  change { query.reset.count }.by(-1)
                )
            end

            it 'should remove the entity from the collection' do
              command.call(primary_key:)

              expect(
                query.map { |item| item[collection.primary_key_name.to_s] }
              )
                .not_to include primary_key
            end
          end
        end
      end
    end
  end
end
