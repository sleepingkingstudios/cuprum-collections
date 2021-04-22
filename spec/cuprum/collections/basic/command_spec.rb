# frozen_string_literal: true

require 'cuprum/collections/basic/command'
require 'cuprum/collections/basic/rspec/command_contract'
require 'cuprum/collections/rspec/fixtures'

RSpec.describe Cuprum::Collections::Basic::Command do
  subject(:command) do
    described_class.new(
      collection_name: collection_name,
      data:            data,
      **constructor_options
    )
  end

  let(:collection_name)     { 'books' }
  let(:data)                { Cuprum::Collections::RSpec::BOOKS_FIXTURES }
  let(:constructor_options) { {} }

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to respond_to(:new)
        .with(0).arguments
        .and_keywords(:collection_name, :data)
        .and_any_keywords
    end
  end

  include_contract Cuprum::Collections::Basic::RSpec::COMMAND_CONTRACT

  describe '#call' do
    it 'should define the method' do
      expect(command)
        .to respond_to(:call)
        .with_unlimited_arguments
        .and_any_keywords
    end

    it 'should return a failing result with not implemented error' do
      expect(command.call)
        .to be_a_failing_result
        .with_error(an_instance_of Cuprum::Errors::CommandNotImplemented)
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
        arguments: [],
        block:     nil,
        keywords:  { primary_key: nil }
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
        expect(command.send(:validate_primary_key, 12_345)).not_to be_a_result
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
          Stannum::Constraints::Types::Array.new(item_type: type)
      end
      errors = contract.errors_for(
        arguments: [],
        block:     nil,
        keywords:  { primary_keys: primary_keys }
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
