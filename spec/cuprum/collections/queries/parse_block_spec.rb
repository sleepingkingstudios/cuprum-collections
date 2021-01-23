# frozen_string_literal: true

require 'cuprum/collections/queries/parse_block'

RSpec.describe Cuprum::Collections::Queries::ParseBlock do
  subject(:command) { described_class.new }

  let(:operators) { Cuprum::Collections::Queries::Operators }

  describe '::Builder' do
    subject(:builder) { described_class.new }

    let(:described_class) { super()::Builder }

    describe '#eq' do
      let(:expected) { [nil, operators::EQUAL, 'Binti: Home'] }

      it { expect(builder.eq 'Binti: Home').to be == expected }

      it { expect(builder.equals 'Binti: Home').to be == expected }
    end

    describe '#ne' do
      let(:expected) { [nil, operators::NOT_EQUAL, 'Binti'] }

      it { expect(builder.ne 'Binti').to be == expected }

      it { expect(builder.not_equal 'Binti').to be == expected }
    end
  end

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

      it 'should not match the parameters' do
        expect(described_class::CONTRACT.matches?(**parameters)).to be false
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

      it 'should match the parameters' do
        expect(described_class::CONTRACT.matches?(**parameters)).to be true
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
    describe 'with a block that raises an error' do
      let(:exception) do
        RuntimeError.new('Something went wrong.')
      end
      let(:block) { -> { Kernel.raise 'Something went wrong.' } }
      let(:expected_error) do
        Cuprum::Collections::Errors::UncaughtException.new(
          exception: exception,
          message:   'uncaught exception when parsing query block'
        )
      end

      it 'should return a failing result' do
        expect(command.call(block: block))
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end

    describe 'with a block that returns nil' do
      let(:block) { -> { nil } }
      let(:expected_error) do
        errors  =
          Cuprum::Collections::Constraints::QueryHash.new.errors_for(nil)
        message = 'query block returned invalid value'

        Cuprum::Collections::Errors::InvalidQuery.new(
          errors:   errors,
          message:  message,
          strategy: :block
        )
      end

      it 'should return a failing result' do
        expect(command.call(block: block))
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end

    describe 'with a block that returns an object' do
      let(:block) { -> { Object.new.freeze } }
      let(:expected_error) do
        errors  =
          Cuprum::Collections::Constraints::QueryHash
          .new
          .errors_for(Object.new.freeze)
        message = 'query block returned invalid value'

        Cuprum::Collections::Errors::InvalidQuery.new(
          errors:   errors,
          message:  message,
          strategy: :block
        )
      end

      it 'should return a failing result' do
        expect(command.call(block: block))
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end

    describe 'with a block that returns an invalid hash' do
      let(:block) { -> { { nil => 'value' } } }
      let(:expected_error) do
        errors  =
          Cuprum::Collections::Constraints::QueryHash
          .new
          .errors_for({ nil => 'value' })
        message = 'query block returned invalid value'

        Cuprum::Collections::Errors::InvalidQuery.new(
          errors:   errors,
          message:  message,
          strategy: :block
        )
      end

      it 'should return a failing result' do
        expect(command.call(block: block))
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end

    describe 'with a block that references an invalid operator' do
      let(:block) { -> { { title: neq('Alecto the Ninth') } } }
      let(:expected_error) do
        Cuprum::Collections::Errors::UnknownOperator.new(operator: :neq)
      end

      it 'should return a failing result' do
        expect(command.call(block: block))
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end

    describe 'with a block that returns an empty hash' do
      let(:block)    { -> { {} } }
      let(:expected) { [] }

      it 'should return a result with empty criteria' do
        expect(command.call(block: block))
          .to be_a_passing_result
          .with_value(expected)
      end
    end

    describe 'with a block that returns a simple value query' do
      let(:block) { -> { { title: 'Gideon the Ninth' } } }
      let(:expected) do
        [
          [
            'title', operators::EQUAL, 'Gideon the Ninth'
          ]
        ]
      end

      it 'should return a result with the expected criteria' do
        expect(command.call(block: block))
          .to be_a_passing_result
          .with_value(expected)
      end
    end

    describe 'with a block that returns an array value query' do
      let(:block) { -> { { tags: %w[Fantasy Modern Romance] } } }
      let(:expected) do
        [
          [
            'tags', operators::EQUAL, %w[Fantasy Modern Romance]
          ]
        ]
      end

      it 'should return a result with the expected criteria' do
        expect(command.call(block: block))
          .to be_a_passing_result
          .with_value(expected)
      end
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
          ['author', operators::EQUAL, 'Nnedi Okorafor'],
          ['series', operators::EQUAL, 'Binti'],
          ['genre',  operators::EQUAL, 'Africanfuturism']
        ]
      end

      it 'should return a result with the expected criteria' do
        expect(command.call(block: block))
          .to be_a_passing_result
          .with_value(expected)
      end
    end

    describe 'with a block that returns an equals query' do
      let(:block) { -> { { title: equals('Gideon the Ninth') } } }
      let(:expected) do
        [
          ['title', operators::EQUAL, 'Gideon the Ninth']
        ]
      end

      it 'should return a result with the expected criteria' do
        expect(command.call(block: block))
          .to be_a_passing_result
          .with_value(expected)
      end
    end

    describe 'with a block that returns a not equal query' do
      let(:block) { -> { { title: not_equal('Harrow the Ninth') } } }
      let(:expected) do
        [
          ['title', operators::NOT_EQUAL, 'Harrow the Ninth']
        ]
      end

      it 'should return a result with the expected criteria' do
        expect(command.call(block: block))
          .to be_a_passing_result
          .with_value(expected)
      end
    end
  end
end
