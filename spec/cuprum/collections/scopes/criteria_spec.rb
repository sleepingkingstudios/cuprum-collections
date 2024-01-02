# frozen_string_literal: true

require 'cuprum/collections/scopes/base'
require 'cuprum/collections/scopes/criteria'
require 'cuprum/collections/rspec/contracts/scopes/criteria_contracts'

RSpec.describe Cuprum::Collections::Scopes::Criteria do
  include Cuprum::Collections::RSpec::Contracts::Scopes::CriteriaContracts

  subject(:scope) { described_class.new(criteria: criteria) }

  let(:described_class) { Spec::ExampleScope }

  example_class 'Spec::ExampleScope', Cuprum::Collections::Scopes::Base \
  do |klass|
    klass.include Cuprum::Collections::Scopes::Criteria # rubocop:disable RSpec/DescribedClass
  end

  describe '::Parser' do
    subject(:parser) { described_class.instance }

    let(:described_class) { Cuprum::Collections::Scopes::Criteria::Parser }

    describe '.instance' do
      include_examples 'should define class reader',
        :instance,
        -> { be_a described_class }

      it { expect(described_class.instance).to be parser }
    end

    describe '#parse' do
      def parse_criteria(*args, &block)
        return parser.parse(&block) if args.empty?

        parser.parse(args.first, &block)
      end

      it 'should define the method' do
        expect(parser).to respond_to(:parse).with(0..1).arguments.and_a_block
      end

      include_contract 'should parse criteria'
    end

    describe '#parse_block' do
      def parse_criteria(&block)
        parser.parse_block(&block)
      end

      it 'should define the method' do
        expect(parser).to respond_to(:parse_block).with(0).arguments.and_a_block
      end

      include_contract 'should parse criteria from a block'
    end

    describe '#parse_hash' do
      def parse_criteria(value)
        parser.parse_hash(value)
      end

      it { expect(parser).to respond_to(:parse_hash).with(1).argument }

      include_contract 'should parse criteria from a hash'
    end
  end

  describe '::UnknownOperatorException' do
    subject(:error) { described_class::UnknownOperatorException.new(message) }

    let(:message) { 'unknown operator "random"' }

    include_examples 'should define constant',
      :UnknownOperatorException,
      -> { be_a(Class).and(be < StandardError) }

    describe '#message' do
      include_examples 'should define reader', :message, -> { message }
    end

    describe '#name' do
      include_examples 'should define reader', :name, nil

      context 'when initialized with name: value' do
        let(:error) do
          described_class::UnknownOperatorException.new(message, name)
        end
        let(:name) { 'random' }

        it { expect(error.name).to be == name }
      end

      context 'when the exception has a cause' do
        let(:name)  { 'random' }
        let(:cause) { NameError.new(nil, name) }

        before(:example) do
          allow(error).to receive(:cause).and_return(cause) # rubocop:disable RSpec/SubjectStub
        end

        it { expect(error.name).to be == name }
      end
    end
  end

  include_contract 'should be a criteria scope', abstract: true
end
