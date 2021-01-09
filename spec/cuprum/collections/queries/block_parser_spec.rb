# frozen_string_literal: true

require 'cuprum/collections/queries/block_parser'

RSpec.describe Cuprum::Collections::Queries::BlockParser do
  subject(:parser) { described_class.new }

  describe '::EQUALS' do
    include_examples 'should define immutable constant', :EQUALS, :eq
  end

  describe '::NOT_EQUAL' do
    include_examples 'should define immutable constant', :NOT_EQUAL, :ne
  end

  describe '::OPERATORS' do
    let(:expected) do
      [
        described_class::EQUALS,
        described_class::NOT_EQUAL
      ]
    end

    include_examples 'should define immutable constant', :OPERATORS

    it { expect(described_class::OPERATORS).to contain_exactly(*expected) }
  end

  describe '.new' do
    it { expect(described_class).to respond_to(:new).with(0).arguments }
  end

  describe '#call' do
    it 'should define the method' do
      expect(parser).to respond_to(:call).with(0).arguments.and_a_block
    end

    describe 'without a block' do
      it 'should raise an exception' do
        expect { parser.call }.to raise_error LocalJumpError, 'no block given'
      end
    end

    describe 'with a block that returns nil' do
      let(:block)         { -> {} }
      let(:error_message) { 'block must return a Hash' }

      it 'should raise an exception' do
        expect { parser.call(&block) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with a block that returns an object' do
      let(:block)         { -> { Object.new.freeze } }
      let(:error_message) { 'block must return a Hash' }

      it 'should raise an exception' do
        expect { parser.call(&block) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with a block that returns an empty hash' do
      let(:block) { -> { {} } }

      it { expect(parser.call(&block)).to be == [] }

      it 'should yield the block in the context of the parser' do # rubocop:disable RSpec/ExampleLength
        yield_context = nil

        parser.call do
          yield_context = self

          {}
        end

        expect(yield_context).to be parser
      end
    end

    describe 'with a block that returns a hash with invalid keys' do
      let(:error_message) { 'hash key must be a non-empty string or symbol' }

      it 'should raise an exception' do
        expect { parser.call { { nil => nil } } }
          .to raise_error RuntimeError, error_message
      end
    end

    describe 'with a block that returns a simple value query' do
      let(:block) { -> { { title: 'Gideon the Ninth' } } }
      let(:expected) do
        [
          ['title', described_class::EQUALS, 'Gideon the Ninth']
        ]
      end

      it { expect(parser.call(&block)).to be == expected }
    end

    describe 'with a block that returns an array value query' do
      let(:block) { -> { { tags: %w[Fantasy Modern Romance] } } }
      let(:expected) do
        [
          ['tags', described_class::EQUALS, %w[Fantasy Modern Romance]]
        ]
      end

      it { expect(parser.call(&block)).to be == expected }
    end

    describe 'with a block that returns a complex value query' do
      let(:block) do
        lambda do
          {
            author: 'Nnedi Okorafor',
            series: 'Binti',
            genre:  'Africanfuturism'
          }
        end
      end
      let(:expected) do
        [
          ['author', described_class::EQUALS, 'Nnedi Okorafor'],
          ['series', described_class::EQUALS, 'Binti'],
          ['genre',  described_class::EQUALS, 'Africanfuturism']
        ]
      end

      it { expect(parser.call(&block)).to be == expected }
    end

    describe 'with a block that returns an equals query' do
      let(:block) { -> { { title: equals('Gideon the Ninth') } } }
      let(:expected) do
        [
          ['title', described_class::EQUALS, 'Gideon the Ninth']
        ]
      end

      it { expect(parser.call(&block)).to be == expected }
    end

    describe 'with a block that returns a not equal query' do
      let(:block) { -> { { title: not_equal('Harrow the Ninth') } } }
      let(:expected) do
        [
          ['title', described_class::NOT_EQUAL, 'Harrow the Ninth']
        ]
      end

      it { expect(parser.call(&block)).to be == expected }
    end
  end

  describe '#eq' do
    let(:expected) { [nil, described_class::EQUALS, 'Binti: Home'] }

    it { expect(parser).to respond_to(:eq).with(1).argument }

    it { expect(parser).to alias_method(:eq).as(:equals) }

    it { expect(parser.eq 'Binti: Home').to be == expected }
  end

  describe '#ne' do
    let(:expected) { [nil, described_class::NOT_EQUAL, 'Binti'] }

    it { expect(parser).to respond_to(:ne).with(1).argument }

    it { expect(parser).to alias_method(:ne).as(:not_equal) }

    it { expect(parser.ne 'Binti').to be == expected }
  end
end
