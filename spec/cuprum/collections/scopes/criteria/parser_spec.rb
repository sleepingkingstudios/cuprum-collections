# frozen_string_literal: true

require 'cuprum/collections/rspec/contracts/scopes/criteria_contracts'
require 'cuprum/collections/scopes/criteria/parser'

RSpec.describe Cuprum::Collections::Scopes::Criteria::Parser do
  include Cuprum::Collections::RSpec::Contracts::Scopes::CriteriaContracts

  subject(:parser) { described_class.instance }

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
    def parse_criteria(...)
      parser.parse_block(...)
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
