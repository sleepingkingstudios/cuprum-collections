# frozen_string_literal: true

require 'cuprum/collections/queries'
require 'cuprum/collections/scope'
require 'cuprum/collections/scopes/criteria'
require 'cuprum/collections/rspec/contracts/scope_contracts'

RSpec.describe Cuprum::Collections::Scopes::Criteria do
  include Cuprum::Collections::RSpec::Contracts::ScopeContracts

  subject(:scope) { described_class.new(criteria: criteria) }

  let(:described_class) { Spec::ExampleScope }

  example_class 'Spec::ExampleScope', Cuprum::Collections::Scope do |klass|
    klass.include Cuprum::Collections::Scopes::Criteria # rubocop:disable RSpec/DescribedClass
  end

  describe '::Parser' do
    subject(:parser) { described_class.instance }

    let(:described_class) { Cuprum::Collections::Scopes::Criteria::Parser }
    let(:operators)       { Cuprum::Collections::Queries::Operators }

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
    include_examples 'should define constant',
      :UnknownOperatorException,
      -> { be_a(Class).and(be < StandardError) }
  end

  include_contract 'should be a criteria scope'
end
