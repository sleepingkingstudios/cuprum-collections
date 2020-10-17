# frozen_string_literal: true

require 'cuprum/collections/parameters_validation'

RSpec.describe Cuprum::Collections::ParametersValidation do
  shared_context 'when the command has parameter validations' do
    example_class 'Spec::Resource', Struct.new(:name)

    before(:example) do
      described_class.argument :resource,   Spec::Resource
      described_class.argument :attributes, Hash, optional: true

      described_class.keyword :color, Integer
      described_class.keyword :shape, String, optional: true
    end
  end

  shared_context 'when the command has a parent class' do
    let(:parent_class)    { Spec::CommandWithParameters }
    let(:described_class) { Spec::CommandSubclassWithParameters }

    example_class 'Spec::CommandSubclassWithParameters',
      'Spec::CommandWithParameters' \
    do |klass|
      klass.include Cuprum::Collections::ParametersValidation # rubocop:disable RSpec/DescribedClass
    end
  end

  shared_context 'when the parent class has parameter validations' do
    before(:example) do
      parent_class.argument :resource,   Object
      parent_class.argument :attributes, Hash

      parent_class.keyword :color,    Integer
      parent_class.keyword :vertices, Array
    end
  end

  subject(:command) { described_class.new }

  let(:described_class) { Spec::CommandWithParameters }

  example_class 'Spec::CommandWithParameters', Cuprum::Command do |klass|
    klass.include Cuprum::Collections::ParametersValidation # rubocop:disable RSpec/DescribedClass
  end

  describe '.argument' do
    let(:builder) { described_class.send(:parameters_contract_builder) }

    before(:example) { allow(builder).to receive(:argument) }

    it 'should define the method' do
      expect(described_class).to respond_to(:argument)
    end

    describe 'with a block' do
      it 'should delegate to builder#argument' do
        described_class.argument(:name, key: :value) {}

        expect(builder).to have_received(:argument).with(:name, key: :value)
      end

      it 'should pass the block to builder#argument' do
        allow(builder).to receive(:argument) { |*_args, &block| block.call }

        expect { |block| described_class.argument(:name, key: :value, &block) }
          .to yield_control
      end
    end

    describe 'with a type' do
      it 'should delegate to builder#argument' do
        described_class.argument(:name, String, key: :value)

        expect(builder)
          .to have_received(:argument)
          .with(:name, String, key: :value)
      end
    end
  end

  describe '.arguments' do
    let(:builder) { described_class.send(:parameters_contract_builder) }

    before(:example) { allow(builder).to receive(:arguments) }

    it 'should define the method' do
      expect(described_class).to respond_to(:arguments)
    end

    it 'should delegate to builder#arguments' do
      described_class.arguments(:tags, String)

      expect(builder).to have_received(:arguments).with(:tags, String)
    end
  end

  describe '.block' do
    let(:builder) { described_class.send(:parameters_contract_builder) }

    before(:example) { allow(builder).to receive(:block) }

    it 'should define the method' do
      expect(described_class).to respond_to(:block)
    end

    it 'should delegate to builder#block' do
      described_class.block(true)

      expect(builder).to have_received(:block).with(true)
    end
  end

  describe '.keyword' do
    let(:builder) { described_class.send(:parameters_contract_builder) }

    before(:example) { allow(builder).to receive(:keyword) }

    it 'should define the method' do
      expect(described_class).to respond_to(:keyword)
    end

    describe 'with a block' do
      it 'should delegate to builder#keyword' do
        described_class.keyword(:name, key: :value) {}

        expect(builder).to have_received(:keyword).with(:name, key: :value)
      end

      it 'should pass the block to builder#keyword' do
        allow(builder).to receive(:keyword) { |*_args, &block| block.call }

        expect { |block| described_class.keyword(:name, key: :value, &block) }
          .to yield_control
      end
    end

    describe 'with a type' do
      it 'should delegate to builder#keyword' do
        described_class.keyword(:name, String, key: :value)

        expect(builder)
          .to have_received(:keyword)
          .with(:name, String, key: :value)
      end
    end
  end

  describe '.keywords' do
    let(:builder) { described_class.send(:parameters_contract_builder) }

    before(:example) { allow(builder).to receive(:keywords) }

    it 'should define the method' do
      expect(described_class).to respond_to(:keywords)
    end

    it 'should delegate to builder#keywords' do
      described_class.keywords(:options, String)

      expect(builder).to have_received(:keywords).with(:options, String)
    end
  end

  describe '.parameters_contract' do
    let(:contract) { described_class.send(:parameters_contract) }

    it 'should define the private class reader', :aggregate_failures do
      expect(described_class).not_to respond_to(:parameters_contract)

      expect(described_class)
        .to respond_to(:parameters_contract, true)
        .with(0).arguments
    end

    it { expect(contract).to be nil }

    wrap_context 'when the command has parameter validations' do
      it { expect(contract).to be_a Stannum::Contracts::ParametersContract }
    end

    wrap_context 'when the command has a parent class' do
      let(:parent_contract) { parent_class.send(:parameters_contract) }

      it { expect(contract).to be nil }

      wrap_context 'when the command has parameter validations' do
        it { expect(contract).to be_a Stannum::Contracts::ParametersContract }

        wrap_context 'when the parent class has parameter validations' do
          it { expect(contract).to be_a Stannum::Contracts::ParametersContract }

          it { expect(contract).not_to be == parent_contract }
        end
      end

      wrap_context 'when the parent class has parameter validations' do
        it { expect(contract).to be == parent_contract }
      end
    end
  end

  describe '.parameters_contract_builder' do
    let(:builder) { described_class.send(:parameters_contract_builder) }

    it 'should define the private class reader', :aggregate_failures do
      expect(described_class).not_to respond_to(:parameters_contract_builder)

      expect(described_class)
        .to respond_to(:parameters_contract_builder, true)
        .with(0).arguments
    end

    it 'should be a parameters contract builder' do
      expect(builder).to be_a Stannum::Contracts::ParametersContract::Builder
    end

    it 'should reference the parameters contract' do
      expect(builder.contract).to be described_class.send(:parameters_contract)
    end

    wrap_context 'when the command has a parent class' do
      it 'should be a parameters contract builder' do
        expect(builder).to be_a Stannum::Contracts::ParametersContract::Builder
      end

      it 'should reference the parameters contract' do
        expect(builder.contract)
          .to be described_class.send(:parameters_contract)
      end
    end
  end

  describe '#call' do
    shared_examples 'should not validate the parameters' do
      it 'should not validate the parameters' do # rubocop:disable RSpec/ExampleLength
        contract = instance_double(
          Stannum::Contracts::ParametersContract,
          match: nil
        )

        allow(Stannum::Contracts::ParametersContract)
          .to receive(:new)
          .and_return(contract)

        call_command

        expect(contract).not_to have_received(:match)
      end
    end

    shared_examples 'should validate the parameters' do
      it 'should validate the parameters' do # rubocop:disable RSpec/ExampleLength
        contract            = described_class.send(:parameters_contract)
        expected_parameters = {
          arguments: arguments,
          keywords:  keywords,
          block:     block
        }

        allow(contract).to receive(:match).and_call_original

        call_command

        expect(contract).to have_received(:match).with(expected_parameters)
      end
    end

    shared_examples 'should not validate the parent parameters' do
      it 'should not validate the parameters with the parent contract' do
        parent_contract = parent_class.send(:parameters_contract)

        allow(parent_contract).to receive(:match)

        call_command

        expect(parent_contract).not_to have_received(:match)
      end
    end

    shared_examples 'should call the original implementation' do
      it 'should call the original implementation' do
        expect(call_command)
          .to be_a_failing_result
          .with_error(an_instance_of Cuprum::Errors::CommandNotImplemented)
      end
    end

    shared_examples 'should fail with a parameters validation error' do
      it 'should fail with a parameters validation error' do
        expect(call_command)
          .to be_a_failing_result
          .with_error(
            an_instance_of Cuprum::Collections::Errors::InvalidParameters
          )
      end

      it 'should return the contract errors' do # rubocop:disable RSpec/ExampleLength
        contract            = described_class.send(:parameters_contract)
        expected_parameters = {
          arguments: arguments,
          keywords:  keywords,
          block:     block
        }

        expect(call_command.error.errors)
          .to be == contract.errors_for(expected_parameters)
      end
    end

    let(:arguments) { [] }
    let(:keywords)  { {} }
    let(:block)     { nil }

    def call_command
      command.call(*arguments, **keywords, &block)
    end

    it 'should define the method' do
      expect(command)
        .to respond_to(:call)
        .with_unlimited_arguments
        .and_any_keywords
        .and_a_block
    end

    include_examples 'should call the original implementation'

    include_examples 'should not validate the parameters'

    wrap_context 'when the command has parameter validations' do
      describe 'with missing parameters' do
        include_examples 'should fail with a parameters validation error'
      end

      describe 'with invalid parameters' do
        let(:arguments) { [Object.new] }
        let(:keywords)  { { color: 'red', shape: 'circle' } }

        include_examples 'should fail with a parameters validation error'
      end

      describe 'with valid parameters' do
        let(:arguments) { [Spec::Resource.new] }
        let(:keywords)  { { color: 0xff3366, shape: 'circle' } }

        include_examples 'should call the original implementation'
      end

      describe 'with extra parameters' do
        let(:arguments) { [Spec::Resource.new, {}, :inverted] }
        let(:keywords)  { { color: 0xff3366, shape: 'circle', size: 'huge' } }

        include_examples 'should fail with a parameters validation error'
      end
    end

    wrap_context 'when the command has a parent class' do
      include_examples 'should call the original implementation'

      include_examples 'should not validate the parameters'

      wrap_context 'when the command has parameter validations' do
        describe 'with missing parameters' do
          include_examples 'should validate the parameters'

          include_examples 'should fail with a parameters validation error'
        end

        describe 'with invalid parameters' do
          let(:arguments) { [Object.new] }
          let(:keywords)  { { color: 'red', shape: 'circle' } }

          include_examples 'should validate the parameters'

          include_examples 'should fail with a parameters validation error'
        end

        describe 'with valid parameters' do
          let(:arguments) { [Spec::Resource.new] }
          let(:keywords)  { { color: 0xff3366, shape: 'circle' } }

          include_examples 'should validate the parameters'

          include_examples 'should call the original implementation'
        end

        describe 'with extra parameters' do
          let(:arguments) { [Spec::Resource.new, {}, :inverted] }
          let(:keywords)  { { color: 0xff3366, shape: 'circle', size: 'huge' } }

          include_examples 'should validate the parameters'

          include_examples 'should fail with a parameters validation error'
        end

        wrap_context 'when the parent class has parameter validations' do
          describe 'with missing parameters' do # rubocop:disable RSpec/NestedGroups
            include_examples 'should validate the parameters'

            include_examples 'should not validate the parent parameters'

            include_examples 'should fail with a parameters validation error'
          end

          describe 'with invalid parameters' do # rubocop:disable RSpec/NestedGroups
            let(:arguments) { [Object.new] }
            let(:keywords)  { { color: 'red', shape: 'circle' } }

            include_examples 'should validate the parameters'

            include_examples 'should not validate the parent parameters'

            include_examples 'should fail with a parameters validation error'
          end

          describe 'with valid parameters' do # rubocop:disable RSpec/NestedGroups
            let(:arguments) { [Spec::Resource.new] }
            let(:keywords)  { { color: 0xff3366, shape: 'circle' } }

            include_examples 'should validate the parameters'

            include_examples 'should not validate the parent parameters'

            include_examples 'should call the original implementation'
          end

          describe 'with extra parameters' do # rubocop:disable RSpec/NestedGroups
            let(:arguments) { [Spec::Resource.new, {}, :inverted] }
            let(:keywords) do
              { color: 0xff3366, shape: 'circle', size: 'huge' }
            end

            include_examples 'should validate the parameters'

            include_examples 'should not validate the parent parameters'

            include_examples 'should fail with a parameters validation error'
          end
        end
      end

      wrap_context 'when the parent class has parameter validations' do
        describe 'with missing parameters' do
          include_examples 'should validate the parameters'

          include_examples 'should fail with a parameters validation error'
        end

        describe 'with invalid parameters' do
          let(:arguments) { [Object.new] }
          let(:keywords)  { { color: 'red', vertices: {} } }

          include_examples 'should validate the parameters'

          include_examples 'should fail with a parameters validation error'
        end

        describe 'with valid parameters' do
          let(:arguments) { [Object.new, {}] }
          let(:keywords)  { { color: 0xff3366, vertices: [] } }

          include_examples 'should validate the parameters'

          include_examples 'should call the original implementation'
        end

        describe 'with extra parameters' do
          let(:arguments) { [Object.new, {}, :inverted] }
          let(:keywords)  { { color: 0xff3366, vertices: [], size: 'huge' } }

          include_examples 'should validate the parameters'

          include_examples 'should fail with a parameters validation error'
        end
      end
    end
  end
end
