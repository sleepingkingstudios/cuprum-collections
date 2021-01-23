# frozen_string_literal: true

require 'cuprum/collections/queries/parse_empty'

RSpec.describe Cuprum::Collections::Queries::ParseEmpty do
  subject(:command) { described_class.new }

  describe '::CONTRACT' do
    include_examples 'should define immutable constant',
      :CONTRACT,
      -> { be_a Stannum::Contracts::ParametersContract }

    describe 'with no parameters' do
      let(:parameters) do
        {
          arguments: [],
          keywords:  {},
          block:     nil
        }
      end

      it 'should match the parameters' do
        expect(described_class::CONTRACT.matches?(**parameters)).to be true
      end
    end

    describe 'with arguments' do
      let(:parameters) do
        {
          arguments: %w[ichi ni san],
          keywords:  {},
          block:     nil
        }
      end

      it 'should not match the parameters' do
        expect(described_class::CONTRACT.matches?(**parameters)).to be false
      end
    end

    describe 'with keywords' do
      let(:parameters) do
        {
          arguments: [],
          keywords:  { one: 1, two: 2, three: 3 },
          block:     nil
        }
      end

      it 'should not match the parameters' do
        expect(described_class::CONTRACT.matches?(**parameters)).to be false
      end
    end

    describe 'with arguments and keywords' do
      let(:parameters) do
        {
          arguments: %w[ichi ni san],
          keywords:  { one: 1, two: 2, three: 3 },
          block:     nil
        }
      end

      it 'should not match the parameters' do
        expect(described_class::CONTRACT.matches?(**parameters)).to be false
      end
    end

    describe 'with a block' do
      let(:parameters) do
        {
          arguments: [],
          keywords:  {},
          block:     -> {}
        }
      end

      it 'should not match the parameters' do
        expect(described_class::CONTRACT.matches?(**parameters)).to be false
      end
    end

    describe 'with arguments and a block' do
      let(:parameters) do
        {
          arguments: %w[ichi ni san],
          keywords:  {},
          block:     -> {}
        }
      end

      it 'should not match the parameters' do
        expect(described_class::CONTRACT.matches?(**parameters)).to be false
      end
    end

    describe 'with keywords and a block' do
      let(:parameters) do
        {
          arguments: [],
          keywords:  { one: 1, two: 2, three: 3 },
          block:     -> {}
        }
      end

      it 'should not match the parameters' do
        expect(described_class::CONTRACT.matches?(**parameters)).to be false
      end
    end

    describe 'with arguments, keywords, and a block' do
      let(:parameters) do
        {
          arguments: %w[ichi ni san],
          keywords:  { one: 1, two: 2, three: 3 },
          block:     -> {}
        }
      end

      it 'should not match the parameters' do
        expect(described_class::CONTRACT.matches?(**parameters)).to be false
      end
    end
  end

  describe '.new' do
    it { expect(described_class).to respond_to(:new).with(0).arguments }
  end

  describe '#call' do
    it { expect(command.call).to be_a_passing_result.with_value([]) }
  end
end
