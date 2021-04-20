# frozen_string_literal: true

require 'cuprum/collections/command'

RSpec.describe Cuprum::Collections::Command do
  subject(:command) { described_class.new }

  describe '.new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end

  describe '.validate_parameters' do
    it 'should define the class method' do
      expect(described_class)
        .to respond_to(:validate_parameters)
        .with(1).argument
        .and_a_block
    end

    it 'should define the singleton class method' do
      expect(described_class.singleton_class)
        .to respond_to(:validate_parameters)
        .with(1).argument
        .and_a_block
    end
  end

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

  describe '#handle_invalid_parameters' do
    let(:errors) { Stannum::Errors.new.add('spec.example_error') }

    def handle_invalid_parameters
      command.send(
        :handle_invalid_parameters,
        errors:      errors,
        method_name: method_name
      )
    end

    it 'should define the private method' do
      expect(command)
        .to respond_to(:handle_invalid_parameters, true)
        .with(0).arguments
        .and_keywords(:errors, :method_name)
    end

    describe 'with method_name: :call' do
      let(:method_name) { :call }
      let(:expected_error) do
        Cuprum::Collections::Errors::InvalidParameters.new(
          command: command,
          errors:  errors
        )
      end

      it 'should return a failing result' do
        expect(handle_invalid_parameters)
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end

    describe 'with another method name' do
      let(:method_name) { :do_something }
      let(:error_message) do
        "invalid parameters for ##{method_name}: #{errors.summary}"
      end

      it 'should raise an exception' do
        expect { handle_invalid_parameters }
          .to raise_error ArgumentError, error_message
      end
    end
  end
end
