# frozen_string_literal: true

require 'cuprum/collections/rspec/deferred/command_examples'
require 'cuprum/collections/rspec/deferred/commands'

module Cuprum::Collections::RSpec::Deferred::Commands
  # Namespace for deferred example groups for validating FindOne commands.
  module FindOneExamples
    include RSpec::SleepingKingStudios::Deferred::Provider

    deferred_examples 'should implement the FindOne command' do
      describe '#call' do
        include Cuprum::Collections::RSpec::Deferred::CommandExamples

        let(:mapped_data) do
          defined?(super()) ? super() : data
        end
        let(:primary_key_name) { defined?(super()) ? super() : 'id' }
        let(:primary_key_type) { defined?(super()) ? super() : Integer }
        let(:invalid_primary_key_value) do
          defined?(super()) ? super() : 100
        end
        let(:valid_primary_key_value) do
          defined?(super()) ? super() : 0
        end
        let(:primary_key) { valid_primary_key_value }
        let(:options)     { {} }

        def call_command
          command.call(primary_key:, **options)
        end

        include_deferred 'should validate the primary key parameter'

        describe 'with an invalid envelope value' do
          let(:options) { super().merge(envelope: Object.new.freeze) }

          include_deferred 'should validate the parameter',
            :envelope,
            'sleeping_king_studios.tools.assertions.boolean'
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
        end

        context 'when the collection has many items' do
          let(:data) { fixtures_data }
          let(:matching_data) do
            mapped_data
              .find { |item| item[primary_key_name.to_s] == primary_key }
          end
          let(:expected_data) do
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
          end

          describe 'with a valid primary key' do
            let(:primary_key) { valid_primary_key_value }

            it 'should return a passing result' do
              expect(command.call(primary_key:))
                .to be_a_passing_result
                .with_value(expected_data)
            end
          end

          describe 'with envelope: true' do
            let(:member_name) { collection.singular_name }

            describe 'with a valid primary key' do
              let(:primary_key) { valid_primary_key_value }

              it 'should return a passing result' do
                expect(command.call(primary_key:, envelope: true))
                  .to be_a_passing_result
                  .with_value({ member_name => expected_data })
              end
            end
          end
        end
      end
    end
  end
end
