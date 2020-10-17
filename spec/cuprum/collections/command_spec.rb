# frozen_string_literal: true

require 'cuprum/collections/command'

RSpec.describe Cuprum::Collections::Command do
  shared_context 'when the command has parameter validations' do
    let(:described_class)     { Spec::ExampleCommand }
    let(:parameters_contract) { described_class.send(:parameters_contract) }

    # rubocop:disable RSpec/DescribedClass
    example_class 'Spec::ExampleCommand',
      Cuprum::Collections::Command \
    do |klass|
      klass.argument :resource,   Object
      klass.argument :attributes, Hash, optional: true

      klass.keyword :color, Integer
      klass.keyword :shape, String, optional: true

      klass.define_method(:process) \
      do |resource, attributes = {}, color:, shape: nil| # rubocop:disable Lint/UnusedBlockArgument
        success(:ok)
      end
    end
    # rubocop:enable RSpec/DescribedClass
  end

  subject(:command) { described_class.new }

  describe '.new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
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

    wrap_context 'when the command has parameter validations' do
      describe 'with invalid parameters with invalid parameters error' do
        let(:expected_errors) do
          parameters_contract
            .errors_for({ arguments: [], keywords: {}, block: nil })
            .to_a
        end

        it 'should return a failing result' do
          expect(command.call)
            .to be_a_failing_result
            .with_error(
              an_instance_of(Cuprum::Collections::Errors::InvalidParameters)
            )
        end

        it 'should return the validation errors' do
          result = command.call

          expect(result.error.errors).to be == expected_errors
        end
      end

      describe 'with valid parameters' do
        let(:arguments) { [Struct.new(:name).new, { name: 'Stem Bolt' }] }
        let(:keywords)  { { color: 0xC0C0C0, shape: 'spiral' } }

        it 'should return a failing result with not implemented error' do
          expect(command.call(*arguments, **keywords))
            .to be_a_passing_result
            .with_value(:ok)
        end
      end
    end
  end
end
