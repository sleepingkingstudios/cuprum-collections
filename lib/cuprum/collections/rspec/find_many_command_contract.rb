# frozen_string_literal: true

require 'cuprum/collections/rspec'

module Cuprum::Collections::RSpec
  # Contract validating the behavior of a FindMany command implementation.
  FIND_MANY_COMMAND_CONTRACT = lambda do
    describe '#call' do
      let(:mapped_data) do
        defined?(super()) ? super() : data
      end
      let(:primary_key_name) { defined?(super()) ? super() : :id }
      let(:primary_key_type) { defined?(super()) ? super() : Integer }
      let(:primary_keys_contract) do
        Stannum::Constraints::Types::ArrayType.new(item_type: primary_key_type)
      end
      let(:invalid_primary_key_values) do
        defined?(super()) ? super() : [100, 101, 102]
      end
      let(:valid_primary_key_values) do
        defined?(super()) ? super() : [0, 1, 2]
      end

      it 'should validate the :allow_partial keyword' do
        expect(command)
          .to validate_parameter(:call, :allow_partial)
          .using_constraint(Stannum::Constraints::Boolean.new)
      end

      it 'should validate the :envelope keyword' do
        expect(command)
          .to validate_parameter(:call, :envelope)
          .using_constraint(Stannum::Constraints::Boolean.new)
      end

      it 'should validate the :primary_keys keyword' do
        expect(command)
          .to validate_parameter(:call, :primary_keys)
          .using_constraint(Array)
      end

      it 'should validate the :primary_keys keyword items' do
        expect(command)
          .to validate_parameter(:call, :primary_keys)
          .with_value([nil])
          .using_constraint(primary_keys_contract)
      end

      it 'should validate the :scope keyword' do
        expect(command)
          .to validate_parameter(:call, :scope)
          .using_constraint(
            Stannum::Constraints::Type.new(query.class, optional: true)
          )
          .with_value(Object.new.freeze)
      end

      describe 'with an array of invalid primary keys' do
        let(:primary_keys) { invalid_primary_key_values }
        let(:expected_error) do
          Cuprum::Collections::Errors::NotFound.new(
            collection_name:    command.collection_name,
            primary_key_name:   primary_key_name,
            primary_key_values: primary_keys
          )
        end

        it 'should return a failing result' do
          expect(command.call(primary_keys: primary_keys))
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
            .compact
        end
        let(:expected_data) do
          defined?(super()) ? super() : matching_data
        end

        describe 'with an array of invalid primary keys' do
          let(:primary_keys) { invalid_primary_key_values }
          let(:expected_error) do
            Cuprum::Collections::Errors::NotFound.new(
              collection_name:    command.collection_name,
              primary_key_name:   primary_key_name,
              primary_key_values: primary_keys
            )
          end

          it 'should return a failing result' do
            expect(command.call(primary_keys: primary_keys))
              .to be_a_failing_result
              .with_error(expected_error)
          end
        end

        describe 'with a partially valid array of primary keys' do
          let(:primary_keys) do
            invalid_primary_key_values + valid_primary_key_values
          end
          let(:expected_error) do
            Cuprum::Collections::Errors::NotFound.new(
              collection_name:    command.collection_name,
              primary_key_name:   primary_key_name,
              primary_key_values: invalid_primary_key_values
            )
          end

          it 'should return a failing result' do
            expect(command.call(primary_keys: primary_keys))
              .to be_a_failing_result
              .with_error(expected_error)
          end
        end

        describe 'with a valid array of primary keys' do
          let(:primary_keys) { valid_primary_key_values }

          it 'should return a passing result' do
            expect(command.call(primary_keys: primary_keys))
              .to be_a_passing_result
              .with_value(expected_data)
          end

          describe 'with an ordered array of primary keys' do
            let(:primary_keys) { valid_primary_key_values.reverse }

            it 'should return a passing result' do
              expect(command.call(primary_keys: primary_keys))
                .to be_a_passing_result
                .with_value(expected_data)
            end
          end
        end

        describe 'with allow_partial: true' do
          describe 'with an array of invalid primary keys' do
            let(:primary_keys) { invalid_primary_key_values }
            let(:expected_error) do
              Cuprum::Collections::Errors::NotFound.new(
                collection_name:    command.collection_name,
                primary_key_name:   primary_key_name,
                primary_key_values: primary_keys
              )
            end

            it 'should return a failing result' do
              expect(command.call(primary_keys: primary_keys))
                .to be_a_failing_result
                .with_error(expected_error)
            end
          end

          describe 'with a partially valid array of primary keys' do
            let(:primary_keys) do
              invalid_primary_key_values + valid_primary_key_values
            end

            it 'should return a passing result' do
              expect(
                command.call(primary_keys: primary_keys, allow_partial: true)
              )
                .to be_a_passing_result
                .with_value(expected_data)
            end
          end

          describe 'with a valid array of primary keys' do
            let(:primary_keys) { valid_primary_key_values }

            it 'should return a passing result' do
              expect(
                command.call(primary_keys: primary_keys, allow_partial: true)
              )
                .to be_a_passing_result
                .with_value(expected_data)
            end

            describe 'with an ordered array of primary keys' do
              let(:primary_keys) { valid_primary_key_values.reverse }

              it 'should return a passing result' do
                expect(
                  command.call(primary_keys: primary_keys, allow_partial: true)
                )
                  .to be_a_passing_result
                  .with_value(expected_data)
              end
            end
          end
        end

        describe 'with envelope: true' do
          describe 'with a valid array of primary keys' do
            let(:primary_keys) { valid_primary_key_values }

            it 'should return a passing result' do
              expect(command.call(primary_keys: primary_keys, envelope: true))
                .to be_a_passing_result
                .with_value({ collection_name => expected_data })
            end

            describe 'with an ordered array of primary keys' do
              let(:primary_keys) { valid_primary_key_values.reverse }

              it 'should return a passing result' do
                expect(command.call(primary_keys: primary_keys, envelope: true))
                  .to be_a_passing_result
                  .with_value({ collection_name => expected_data })
              end
            end
          end
        end

        describe 'with scope: query' do
          let(:scope_filter) { -> { {} } }

          describe 'with an array of invalid primary keys' do
            let(:primary_keys) { invalid_primary_key_values }
            let(:expected_error) do
              Cuprum::Collections::Errors::NotFound.new(
                collection_name:    command.collection_name,
                primary_key_name:   primary_key_name,
                primary_key_values: primary_keys
              )
            end

            it 'should return a failing result' do
              expect(command.call(primary_keys: primary_keys, scope: scope))
                .to be_a_failing_result
                .with_error(expected_error)
            end
          end

          describe 'with a scope that does not match any keys' do
            let(:scope_filter) { -> { { author: 'Ursula K. LeGuin' } } }

            describe 'with a valid array of primary keys' do
              let(:primary_keys) { valid_primary_key_values }
              let(:expected_error) do
                Cuprum::Collections::Errors::NotFound.new(
                  collection_name:    command.collection_name,
                  primary_key_name:   primary_key_name,
                  primary_key_values: primary_keys
                )
              end

              it 'should return a failing result' do
                expect(command.call(primary_keys: primary_keys, scope: scope))
                  .to be_a_failing_result
                  .with_error(expected_error)
              end
            end
          end

          describe 'with a scope that matches some keys' do
            let(:scope_filter) { -> { { series: nil } } }
            let(:matching_data) do
              super().select { |item| item['series'].nil? }
            end

            describe 'with a valid array of primary keys' do
              let(:primary_keys) { valid_primary_key_values }
              let(:expected_error) do
                found_keys   =
                  matching_data.map { |item| item[primary_key_name.to_s] }
                missing_keys = primary_keys - found_keys

                Cuprum::Collections::Errors::NotFound.new(
                  collection_name:    command.collection_name,
                  primary_key_name:   primary_key_name,
                  primary_key_values: missing_keys
                )
              end

              it 'should return a failing result' do
                expect(command.call(primary_keys: primary_keys, scope: scope))
                  .to be_a_failing_result
                  .with_error(expected_error)
              end
            end

            describe 'with allow_partial: true' do
              describe 'with a valid array of primary keys' do
                let(:primary_keys) { valid_primary_key_values }

                it 'should return a passing result' do
                  expect(
                    command.call(
                      allow_partial: true,
                      primary_keys:  primary_keys,
                      scope:         scope
                    )
                  )
                    .to be_a_passing_result
                    .with_value(expected_data)
                end
              end
            end
          end

          describe 'with a scope that matches all keys' do
            let(:scope_filter) { -> { { author: 'J.R.R. Tolkien' } } }

            describe 'with a valid array of primary keys' do
              let(:primary_keys) { valid_primary_key_values }

              it 'should return a passing result' do
                expect(command.call(primary_keys: primary_keys))
                  .to be_a_passing_result
                  .with_value(expected_data)
              end
            end
          end
        end
      end
    end
  end
end
