# frozen_string_literal: true

require 'cuprum/collections/rspec/deferred/command_examples'
require 'cuprum/collections/rspec/deferred/commands'

module Cuprum::Collections::RSpec::Deferred::Commands
  # Namespace for deferred example groups for validating FindMany commands.
  module FindManyExamples
    include RSpec::SleepingKingStudios::Deferred::Provider

    deferred_examples 'should implement the FindMany command' do
      describe '#call' do
        include Cuprum::Collections::RSpec::Deferred::CommandExamples

        let(:mapped_data) do
          defined?(super()) ? super() : data
        end
        let(:primary_key_name) { defined?(super()) ? super() : 'id' }
        let(:primary_key_type) { defined?(super()) ? super() : Integer }
        let(:invalid_primary_key_values) do
          defined?(super()) ? super() : [100, 101, 102]
        end
        let(:valid_primary_key_values) do
          defined?(super()) ? super() : [0, 1, 2]
        end
        let(:primary_keys) { [] }
        let(:options)      { {} }

        def call_command
          command.call(primary_keys:, **options)
        end

        include_deferred 'should validate the primary keys parameter'

        describe 'with an invalid allow_partial value' do
          let(:options) { super().merge(allow_partial: Object.new.freeze) }

          include_deferred 'should validate the parameter',
            :allow_partial,
            'sleeping_king_studios.tools.assertions.boolean'
        end

        describe 'with an invalid envelope value' do
          let(:options) { super().merge(envelope: Object.new.freeze) }

          include_deferred 'should validate the parameter',
            :envelope,
            'sleeping_king_studios.tools.assertions.boolean'
        end

        describe 'with an empty array of primary keys' do
          let(:primary_keys)  { [] }
          let(:expected_data) { [] }

          it 'should return a passing result' do
            expect(command.call(primary_keys:))
              .to be_a_passing_result
              .with_value(expected_data)
          end
        end

        describe 'with an array of invalid primary keys' do
          let(:primary_keys) { invalid_primary_key_values }
          let(:expected_error) do
            Cuprum::Errors::MultipleErrors.new(
              errors: primary_keys.map do |primary_key|
                Cuprum::Collections::Errors::NotFound.new(
                  attribute_name:  collection.primary_key_name,
                  attribute_value: primary_key,
                  collection_name: collection.name,
                  primary_key:     true
                )
              end
            )
          end

          it 'should return a failing result' do
            expect(command.call(primary_keys:))
              .to be_a_failing_result
              .with_error(expected_error)
          end
        end

        context 'when the collection has many items' do
          let(:data) { fixtures_data }
          let(:matching_data) do
            primary_keys
              .map do |key|
                mapped_data.find { |item| item[primary_key_name.to_s] == key }
              end
          end
          let(:expected_data) do
            defined?(super()) ? super() : matching_data
          end

          describe 'with an empty array of primary keys' do
            let(:primary_keys)  { [] }
            let(:expected_data) { [] }

            it 'should return a passing result' do
              expect(command.call(primary_keys:))
                .to be_a_passing_result
                .with_value(expected_data)
            end
          end

          describe 'with an array of invalid primary keys' do
            let(:primary_keys) { invalid_primary_key_values }
            let(:expected_error) do
              Cuprum::Errors::MultipleErrors.new(
                errors: primary_keys.map do |primary_key|
                  Cuprum::Collections::Errors::NotFound.new(
                    attribute_name:  collection.primary_key_name,
                    attribute_value: primary_key,
                    collection_name: collection.name,
                    primary_key:     true
                  )
                end
              )
            end

            it 'should return a failing result' do
              expect(command.call(primary_keys:))
                .to be_a_failing_result
                .with_error(expected_error)
            end
          end

          describe 'with a partially valid array of primary keys' do
            let(:primary_keys) do
              invalid_primary_key_values + valid_primary_key_values
            end
            let(:expected_error) do
              Cuprum::Errors::MultipleErrors.new(
                errors: primary_keys.map do |primary_key|
                  unless invalid_primary_key_values.include?(primary_key)
                    next nil
                  end

                  Cuprum::Collections::Errors::NotFound.new(
                    attribute_name:  collection.primary_key_name,
                    attribute_value: primary_key,
                    collection_name: collection.name,
                    primary_key:     true
                  )
                end
              )
            end

            it 'should return a failing result' do
              expect(command.call(primary_keys:))
                .to be_a_failing_result
                .with_error(expected_error)
            end
          end

          describe 'with a valid array of primary keys' do
            let(:primary_keys) { valid_primary_key_values }

            it 'should return a passing result' do
              expect(command.call(primary_keys:))
                .to be_a_passing_result
                .with_value(expected_data)
            end

            describe 'with an ordered array of primary keys' do
              let(:primary_keys) { valid_primary_key_values.reverse }

              it 'should return a passing result' do
                expect(command.call(primary_keys:))
                  .to be_a_passing_result
                  .with_value(expected_data)
              end
            end
          end

          describe 'with allow_partial: true' do
            describe 'with an array of invalid primary keys' do
              let(:primary_keys) { invalid_primary_key_values }
              let(:expected_error) do
                Cuprum::Errors::MultipleErrors.new(
                  errors: invalid_primary_key_values.map do |primary_key|
                    Cuprum::Collections::Errors::NotFound.new(
                      attribute_name:  collection.primary_key_name,
                      attribute_value: primary_key,
                      collection_name: collection.name,
                      primary_key:     true
                    )
                  end
                )
              end

              it 'should return a failing result' do
                expect(command.call(primary_keys:))
                  .to be_a_failing_result
                  .with_error(expected_error)
              end
            end

            describe 'with a partially valid array of primary keys' do
              let(:primary_keys) do
                invalid_primary_key_values + valid_primary_key_values
              end
              let(:expected_error) do
                Cuprum::Errors::MultipleErrors.new(
                  errors: primary_keys.map do |primary_key|
                    unless invalid_primary_key_values.include?(primary_key)
                      next nil
                    end

                    Cuprum::Collections::Errors::NotFound.new(
                      attribute_name:  collection.primary_key_name,
                      attribute_value: primary_key,
                      collection_name: collection.name,
                      primary_key:     true
                    )
                  end
                )
              end

              it 'should return a passing result' do
                expect(
                  command.call(
                    primary_keys:,
                    allow_partial: true
                  )
                )
                  .to be_a_passing_result
                  .with_value(expected_data)
                  .and_error(expected_error)
              end
            end

            describe 'with a valid array of primary keys' do
              let(:primary_keys) { valid_primary_key_values }

              it 'should return a passing result' do
                expect(
                  command.call(
                    primary_keys:,
                    allow_partial: true
                  )
                )
                  .to be_a_passing_result
                  .with_value(expected_data)
              end

              describe 'with an ordered array of primary keys' do
                let(:primary_keys) { valid_primary_key_values.reverse }

                it 'should return a passing result' do
                  expect(
                    command.call(
                      primary_keys:,
                      allow_partial: true
                    )
                  )
                    .to be_a_passing_result
                    .with_value(expected_data)
                end
              end
            end
          end

          describe 'with envelope: true' do
            describe 'with an empty array of primary keys' do
              let(:primary_keys)  { [] }
              let(:expected_data) { [] }

              it 'should return a passing result' do
                expect(
                  command.call(primary_keys:, envelope: true)
                )
                  .to be_a_passing_result
                  .with_value({ collection.name => expected_data })
              end
            end

            describe 'with a valid array of primary keys' do
              let(:primary_keys) { valid_primary_key_values }

              it 'should return a passing result' do
                expect(
                  command.call(primary_keys:, envelope: true)
                )
                  .to be_a_passing_result
                  .with_value({ collection.name => expected_data })
              end

              describe 'with an ordered array of primary keys' do
                let(:primary_keys) { valid_primary_key_values.reverse }

                it 'should return a passing result' do
                  expect(
                    command.call(primary_keys:, envelope: true)
                  )
                    .to be_a_passing_result
                    .with_value({ collection.name => expected_data })
                end
              end
            end
          end
        end
      end
    end
  end
end
