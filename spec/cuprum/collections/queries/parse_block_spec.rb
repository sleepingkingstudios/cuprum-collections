# frozen_string_literal: true

require 'cuprum/collections/queries/parse_block'

RSpec.describe Cuprum::Collections::Queries::ParseBlock do
  subject(:command) { described_class.new }

  let(:operators) { Cuprum::Collections::Queries::Operators }

  describe '::Builder' do
    subject(:builder) { described_class.new }

    let(:described_class) { super()::Builder }

    describe '#equal' do
      let(:expected) { [nil, operators::EQUAL, 'Binti: Home'] }

      it { expect(builder.eq 'Binti: Home').to be == expected }

      it { expect(builder.equal 'Binti: Home').to be == expected }

      it { expect(builder.equals 'Binti: Home').to be == expected }
    end

    describe '#not_equal' do
      let(:expected) { [nil, operators::NOT_EQUAL, 'Binti'] }

      it { expect(builder.ne 'Binti').to be == expected }

      it { expect(builder.not_equal 'Binti').to be == expected }
    end

    describe '#not_one_of' do
      let(:value)    { ['Binti', 'Binti: Home'] }
      let(:expected) { [nil, operators::NOT_ONE_OF, value] }

      it { expect(builder.not_one_of value).to be == expected }
    end

    describe '#one_of' do
      let(:value)    { ['Binti', 'Binti: Home'] }
      let(:expected) { [nil, operators::ONE_OF, value] }

      it { expect(builder.one_of value).to be == expected }
    end
  end

  describe '.new' do
    it { expect(described_class).to respond_to(:new).with(0).arguments }
  end

  describe '.match' do
    let(:keywords) { {} }
    let(:parameters) do
      {
        arguments: [],
        block:     nil,
        keywords:  keywords
      }
    end
    let(:result) { described_class.match(**parameters).first }
    let(:errors) { described_class.match(**parameters).last }
    let(:expected_errors) do
      contract = Stannum::Contracts::ParametersContract.new do
        keyword :where, Proc
      end

      contract.errors_for(parameters)
    end

    describe 'with no parameters' do
      it { expect(result).to be false }

      it { expect(errors).to be == expected_errors }
    end

    describe 'with where: nil' do
      let(:keywords) { { where: nil } }

      it { expect(result).to be false }

      it { expect(errors).to be == expected_errors }
    end

    describe 'with where: an Object' do
      let(:keywords) { { where: Object.new.freeze } }

      it { expect(result).to be false }

      it { expect(errors).to be == expected_errors }
    end

    describe 'with where: a Hash' do
      let(:keywords) { { where: { title: 'On Basilisk Station' } } }

      it { expect(result).to be false }

      it { expect(errors).to be == expected_errors }
    end

    describe 'with where: a Proc' do
      let(:keywords) { { where: -> { { title: 'On Basilisk Station' } } } }

      it { expect(result).to be true }

      it { expect(errors).to be == Stannum::Errors.new }
    end
  end

  describe '#call' do
    it 'should validate the :where keyword' do
      expect(command)
        .to validate_parameter(:call, :where)
        .using_constraint(Proc)
    end

    describe 'with a block that raises an error' do
      let(:exception) do
        RuntimeError.new('Something went wrong.')
      end
      let(:block) { -> { Kernel.raise 'Something went wrong.' } }
      let(:expected_error) do
        Cuprum::Errors::UncaughtException.new(
          exception: exception,
          message:   'uncaught exception when parsing query block'
        )
      end

      it 'should return a failing result' do
        expect(command.call(where: block))
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end

    describe 'with a block that returns nil' do
      let(:block) { -> {} }
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
        expect(command.call(where: block))
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end

    describe 'with a block that returns an object' do
      let(:block) { -> { Object.new.freeze } }
      let(:expected_error) do
        errors  = Cuprum::Collections::Constraints::QueryHash
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
        expect(command.call(where: block))
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end

    describe 'with a block that returns an invalid hash' do
      let(:block) { -> { { nil => 'value' } } }
      let(:expected_error) do
        errors  = Cuprum::Collections::Constraints::QueryHash
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
        expect(command.call(where: block))
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
        expect(command.call(where: block))
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end

    describe 'with a block that returns an empty hash' do
      let(:block)    { -> { {} } }
      let(:expected) { [] }

      it 'should return a result with empty criteria' do
        expect(command.call(where: block))
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
        expect(command.call(where: block))
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
        expect(command.call(where: block))
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
        expect(command.call(where: block))
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
        expect(command.call(where: block))
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
        expect(command.call(where: block))
          .to be_a_passing_result
          .with_value(expected)
      end
    end
  end
end
