# frozen_string_literal: true

require 'stannum/constraints/types/hash_with_string_keys'

require 'cuprum/collections/rspec/deferred/command_examples'

require 'support/book'
require 'support/examples/basic'

module Spec::Support::Examples::Basic
  module CommandExamples
    include RSpec::SleepingKingStudios::Deferred::Provider

    deferred_context 'with a collection with a custom primary key' do
      let(:primary_key_name) { :uuid }
      let(:primary_key_type) { String }
      let(:collection_options) do
        super().merge(
          primary_key_name:,
          primary_key_type:
        )
      end
      let(:mapped_data) do
        data.map do |item|
          item.dup.tap do |hsh|
            value = hsh.delete('id').to_s.rjust(12, '0')

            hsh['uuid'] = "00000000-0000-0000-0000-#{value}"
          end
        end
      end
      let(:invalid_primary_key_value) do
        '00000000-0000-0000-0000-000000000100'
      end
      let(:valid_primary_key_value) do
        '00000000-0000-0000-0000-000000000000'
      end
      let(:invalid_primary_key_values) do
        %w[
          00000000-0000-0000-0000-000000000100
          00000000-0000-0000-0000-000000000101
          00000000-0000-0000-0000-000000000102
        ]
      end
      let(:valid_primary_key_values) do
        %w[
          00000000-0000-0000-0000-000000000000
          00000000-0000-0000-0000-000000000001
          00000000-0000-0000-0000-000000000002
        ]
      end
    end

    deferred_context 'with parameters for a basic command' do
      let(:collection) do
        Cuprum::Collections::Basic::Collection.new(
          data: mapped_data,
          name: 'books',
          **collection_options
        )
      end
      let(:collection_options)  { {} }
      let(:data)                { [] }
      let(:mapped_data)         { data }
      let(:fixtures_data) do
        Cuprum::Collections::RSpec::Fixtures::BOOKS_FIXTURES.dup
      end
      let(:entity_type) do
        # @todo Parameter Validation
        Stannum::Constraints::Types::HashWithStringKeys.new
      end
    end

    deferred_examples 'should implement the Basic::Command methods' do
      include Cuprum::Collections::RSpec::Deferred::CommandExamples

      include_deferred 'should implement the CollectionCommand methods'

      describe '.new' do
        it 'should define the constructor' do
          expect(described_class)
            .to respond_to(:new)
            .with(0).arguments
            .and_keywords(:collection)
        end
      end

      describe '#data' do
        include_examples 'should define reader', :data, -> { collection.data }
      end

      describe '#default_contract' do
        include_examples 'should define reader',
          :default_contract,
          -> { collection.default_contract }
      end

      describe '#validate_primary_key' do
        let(:primary_key_type) { Integer }
        let(:expected_error) do
          type     = primary_key_type
          contract = Stannum::Contracts::ParametersContract.new do
            keyword :primary_key, type
          end
          errors = contract.errors_for(
            {
              arguments: [],
              block:     nil,
              keywords:  { primary_key: nil }
            }
          )

          Cuprum::Collections::Errors::InvalidParameters.new(
            command:,
            errors:
          )
        end

        it 'should define the private method' do
          expect(command)
            .to respond_to(:validate_primary_key, true)
            .with(1).argument
        end

        describe 'with nil' do
          it 'should return a failing result' do
            expect(command.send(:validate_primary_key, nil))
              .to be_a_failing_result
              .with_error(expected_error)
          end
        end

        describe 'with an Object' do
          it 'should return a failing result' do
            expect(command.send(:validate_primary_key, Object.new.freeze))
              .to be_a_failing_result
              .with_error(expected_error)
          end
        end

        describe 'with a String' do
          it 'should return a failing result' do
            expect(command.send(:validate_primary_key, '12345'))
              .to be_a_failing_result
              .with_error(expected_error)
          end
        end

        describe 'with an Integer' do
          it 'should not return a result' do
            expect(command.send(:validate_primary_key, 12_345))
              .not_to be_a_result
          end
        end

        context 'when initialized with a primary key type' do
          let(:primary_key_type) { String }
          let(:collection_options) do
            super().merge({ primary_key_type: })
          end

          describe 'with an Integer' do
            it 'should return a failing result' do
              expect(command.send(:validate_primary_key, 12_345))
                .to be_a_failing_result
                .with_error(expected_error)
            end
          end

          describe 'with a String' do
            it 'should not return a result' do
              expect(command.send(:validate_primary_key, '12345'))
                .not_to be_a_result
            end
          end
        end
      end

      describe '#validate_primary_keys' do
        let(:primary_keys)     { nil }
        let(:primary_key_type) { Integer }
        let(:expected_error) do
          type     = primary_key_type
          contract = Stannum::Contracts::ParametersContract.new do
            keyword :primary_keys,
              Stannum::Constraints::Types::ArrayType.new(item_type: type)
          end
          errors = contract.errors_for(
            {
              arguments: [],
              block:     nil,
              keywords:  { primary_keys: }
            }
          )

          Cuprum::Collections::Errors::InvalidParameters.new(
            command:,
            errors:
          )
        end

        it 'should define the private method' do
          expect(command)
            .to respond_to(:validate_primary_keys, true)
            .with(1).argument
        end

        describe 'with nil' do
          it 'should return a failing result' do
            expect(command.send(:validate_primary_keys, nil))
              .to be_a_failing_result
              .with_error(expected_error)
          end
        end

        describe 'with an Object' do
          it 'should return a failing result' do
            expect(command.send(:validate_primary_keys, Object.new.freeze))
              .to be_a_failing_result
              .with_error(expected_error)
          end
        end

        describe 'with a String' do
          it 'should return a failing result' do
            expect(command.send(:validate_primary_keys, '12345'))
              .to be_a_failing_result
              .with_error(expected_error)
          end
        end

        describe 'with an Integer' do
          it 'should return a failing result' do
            expect(command.send(:validate_primary_keys, 12_345))
              .to be_a_failing_result
              .with_error(expected_error)
          end
        end

        describe 'with an empty Array' do
          it 'should not return a result' do
            expect(command.send(:validate_primary_keys, []))
              .not_to be_a_result
          end
        end

        describe 'with an Array with nil values' do
          let(:primary_keys) { Array.new(3, nil) }

          it 'should return a failing result' do
            expect(command.send(:validate_primary_keys, primary_keys))
              .to be_a_failing_result
              .with_error(expected_error)
          end
        end

        describe 'with an Array with Object values' do
          let(:primary_keys) { Array.new(3) { Object.new.freeze } }

          it 'should return a failing result' do
            expect(command.send(:validate_primary_keys, primary_keys))
              .to be_a_failing_result
              .with_error(expected_error)
          end
        end

        describe 'with an Array with String values' do
          let(:primary_keys) { %w[ichi ni san] }

          it 'should return a failing result' do
            expect(command.send(:validate_primary_keys, primary_keys))
              .to be_a_failing_result
              .with_error(expected_error)
          end
        end

        describe 'with an Array with Integer values' do
          it 'should not return a result' do
            expect(command.send(:validate_primary_keys, [0, 1, 2]))
              .not_to be_a_result
          end
        end
      end
    end
  end
end
