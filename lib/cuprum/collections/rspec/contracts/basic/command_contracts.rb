# frozen_string_literal: true

require 'cuprum/collections/rspec/contracts/basic'

module Cuprum::Collections::RSpec::Contracts::Basic
  # Contracts for asserting on Basic::Command objects.
  module CommandContracts
    # Contract validating the behavior of a basic command implementation.
    module ShouldBeABasicCommandContract
      extend RSpec::SleepingKingStudios::Contract

      # @!method apply(example_group)
      #   Adds the contract to the example group.
      #
      #   @param example_group [RSpec::Core::ExampleGroup] the example group to
      #     which the contract is applied.
      contract do
        describe '.subclass' do
          let(:subclass) { described_class.subclass }
          let(:constructor_options) do
            {
              collection_name: 'books',
              data:            data,
              optional_key:    'optional value'
            }
          end

          it 'should define the class method' do
            expect(described_class)
              .to respond_to(:subclass)
              .with(0).arguments
              .and_any_keywords
          end

          it { expect(subclass).to be_a Class }

          it { expect(subclass).to be < described_class }

          it 'should define the constructor' do
            expect(subclass)
              .to respond_to(:new)
              .with(0).arguments
              .and_any_keywords
          end

          it 'should return the collection name' do
            expect(subclass.new(**constructor_options).collection_name)
              .to be collection_name
          end

          it 'should return the data' do
            expect(subclass.new(**constructor_options).data)
              .to be data
          end

          it 'should return the options' do
            expect(subclass.new(**constructor_options).options)
              .to be == { optional_key: 'optional value' }
          end

          describe 'with options' do
            let(:default_options) do
              {
                collection_name: 'books',
                custom_key:      'custom value'
              }
            end
            let(:constructor_options) do
              {
                data:         data,
                optional_key: 'optional value'
              }
            end
            let(:subclass) { described_class.subclass(**default_options) }

            it { expect(subclass).to be_a Class }

            it { expect(subclass).to be < described_class }

            it 'should define the constructor' do
              expect(subclass)
                .to respond_to(:new)
                .with(0).arguments
                .and_any_keywords
            end

            it 'should return the collection name' do
              expect(subclass.new(**constructor_options).collection_name)
                .to be collection_name
            end

            it 'should return the data' do
              expect(subclass.new(**constructor_options).data)
                .to be data
            end

            it 'should return the options' do
              expect(subclass.new(**constructor_options).options)
                .to be == {
                  custom_key:   'custom value',
                  optional_key: 'optional value'
                }
            end
          end
        end

        describe '#collection_name' do
          include_examples 'should have reader',
            :collection_name,
            -> { collection_name }

          context 'when initialized with collection_name: symbol' do
            let(:collection_name) { :books }

            it { expect(command.collection_name).to be == collection_name.to_s }
          end
        end

        describe '#data' do
          include_examples 'should define reader', :data, -> { data }
        end

        describe '#default_contract' do
          include_examples 'should define reader', :default_contract, nil

          context 'when initialized with a default contract' do
            let(:default_contract) { Stannum::Contract.new }
            let(:constructor_options) do
              super().merge(default_contract: default_contract)
            end

            it { expect(command.default_contract).to be default_contract }
          end
        end

        describe '#member_name' do
          def tools
            SleepingKingStudios::Tools::Toolbelt.instance
          end

          include_examples 'should have reader',
            :member_name,
            -> { tools.str.singularize(collection_name) }

          context 'when initialized with collection_name: value' do
            let(:collection_name) { :books }

            it 'should return the singular collection name' do
              expect(command.member_name)
                .to be == tools.str.singularize(collection_name.to_s)
            end
          end

          context 'when initialized with member_name: string' do
            let(:member_name) { 'tome' }
            let(:constructor_options) do
              super().merge(member_name: member_name)
            end

            it 'should return the singular collection name' do
              expect(command.member_name).to be member_name
            end
          end

          context 'when initialized with member_name: symbol' do
            let(:member_name) { :tome }
            let(:constructor_options) do
              super().merge(member_name: member_name)
            end

            it 'should return the singular collection name' do
              expect(command.member_name).to be == member_name.to_s
            end
          end
        end

        describe '#options' do
          let(:expected_options) do
            defined?(super()) ? super() : constructor_options
          end

          include_examples 'should define reader',
            :options,
            -> { be == expected_options }

          context 'when initialized with options' do
            let(:constructor_options) { super().merge({ key: 'value' }) }
            let(:expected_options)    { super().merge({ key: 'value' }) }

            it { expect(command.options).to be == expected_options }
          end
        end

        describe '#primary_key_name' do
          include_examples 'should define reader', :primary_key_name, :id

          context 'when initialized with a primary key name' do
            let(:primary_key_name) { :uuid }
            let(:constructor_options) do
              super().merge({ primary_key_name: primary_key_name })
            end

            it { expect(command.primary_key_name).to be == primary_key_name }
          end
        end

        describe '#primary_key_type' do
          include_examples 'should define reader', :primary_key_type, Integer

          context 'when initialized with a primary key type' do
            let(:primary_key_type) { String }
            let(:constructor_options) do
              super().merge({ primary_key_type: primary_key_type })
            end

            it { expect(command.primary_key_type).to be == primary_key_type }
          end
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
              command: command,
              errors:  errors
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
            let(:constructor_options) do
              super().merge({ primary_key_type: primary_key_type })
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
                keywords:  { primary_keys: primary_keys }
              }
            )

            Cuprum::Collections::Errors::InvalidParameters.new(
              command: command,
              errors:  errors
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

    # Contract defining contexts for validating basic commands.
    module WithBasicCommandContextsContract
      extend RSpec::SleepingKingStudios::Contract

      # @!method apply(example_group)
      #   Adds the contract to the example group.
      #
      #   @param example_group [RSpec::Core::ExampleGroup] the example group to
      #     which the contract is applied.
      contract do
        shared_context 'with parameters for a basic contract' do
          let(:collection_name)     { 'books' }
          let(:data)                { [] }
          let(:mapped_data)         { data }
          let(:constructor_options) { {} }
          let(:expected_options)    { {} }
          let(:primary_key_name)    { :id }
          let(:primary_key_type)    { Integer }
          let(:entity_type) do
            Stannum::Constraints::Types::HashWithStringKeys.new
          end
          let(:fixtures_data) do
            Cuprum::Collections::RSpec::BOOKS_FIXTURES.dup
          end
          let(:query) do
            Cuprum::Collections::Basic::Query.new(mapped_data)
          end
          let(:scope) do
            Cuprum::Collections::Basic::Query
              .new(mapped_data).where(scope_filter)
          end
        end

        shared_context 'with a custom primary key' do
          let(:primary_key_name) { :uuid }
          let(:primary_key_type) { String }
          let(:constructor_options) do
            super().merge(
              primary_key_name: primary_key_name,
              primary_key_type: primary_key_type
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
      end
    end
  end
end
