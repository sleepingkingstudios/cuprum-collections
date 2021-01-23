# frozen_string_literal: true

require 'cuprum/collections/queries/parse_strategy'

RSpec.describe Cuprum::Collections::Queries::ParseStrategy do
  subject(:command) { described_class.new }

  describe '::UNKNOWN_STRATEGY_ERROR' do
    include_examples 'should define immutable constant',
      :UNKNOWN_STRATEGY_ERROR,
      'cuprum.collections.errors.queries.unknown_strategy'
  end

  describe '.new' do
    it { expect(described_class).to respond_to(:new).with(0).arguments }
  end

  describe '#call' do
    describe 'with no parameters' do
      it 'should return a passing result with the ParseEmpty strategy' do
        expect(command.call)
          .to be_a_passing_result
          .with_value(be_a Cuprum::Collections::Queries::ParseEmpty)
      end
    end

    describe 'with a block' do
      it 'should return a passing result with the ParseBlock strategy' do
        expect(command.call block: -> {})
          .to be_a_passing_result
          .with_value(be_a Cuprum::Collections::Queries::ParseBlock)
      end
    end

    describe 'with invalid parameters' do
      let(:arguments) { %w[ichi ni san] }
      let(:keywords)  { { one: 1, two: 2, three: 3 } }
      let(:expected_error) do
        errors = Stannum::Errors.new
        errors[:strategy].add(
          described_class::UNKNOWN_STRATEGY_ERROR,
          strategy: nil
        )

        Cuprum::Collections::Errors::InvalidQuery.new(
          errors:   errors,
          strategy: nil
        )
      end

      it 'should return a failing result' do
        expect(command.call arguments: arguments, keywords: keywords)
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end

    describe 'with strategy: an invalid strategy' do
      let(:strategy) { :randomize }
      let(:expected_error) do
        errors = Stannum::Errors.new
        errors[:strategy].add(
          described_class::UNKNOWN_STRATEGY_ERROR,
          strategy: strategy
        )

        Cuprum::Collections::Errors::InvalidQuery.new(
          errors:   errors,
          strategy: strategy
        )
      end

      it 'should return a failing result' do
        expect(command.call strategy: strategy)
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end

    describe 'with strategy: :block' do
      let(:strategy) { :block }

      describe 'with a block' do
        it 'should return a passing result with the ParseBlock strategy' do
          expect(command.call block: -> {}, strategy: strategy)
            .to be_a_passing_result
            .with_value(be_a Cuprum::Collections::Queries::ParseBlock)
        end
      end

      describe 'with invalid parameters' do
        let(:arguments) { %w[ichi ni san] }
        let(:keywords)  { { one: 1, two: 2, three: 3 } }
        let(:result) do
          command.call(
            arguments: arguments,
            keywords:  keywords,
            strategy:  strategy
          )
        end
        let(:expected_error) do
          contract = Cuprum::Collections::Queries::ParseBlock::CONTRACT
          errors   = contract.errors_for(
            arguments: arguments,
            keywords:  keywords
          )

          Cuprum::Collections::Errors::InvalidQuery.new(
            errors:   errors,
            strategy: strategy
          )
        end

        it 'should return a failing result' do
          expect(result)
            .to be_a_failing_result
            .with_error(expected_error)
        end
      end
    end

    describe 'with strategy: :empty' do
      let(:strategy) { :empty }

      describe 'with no parameters' do
        it 'should return a passing result with the ParseEmpty strategy' do
          expect(command.call(strategy: strategy))
            .to be_a_passing_result
            .with_value(be_a Cuprum::Collections::Queries::ParseEmpty)
        end
      end

      describe 'with invalid parameters' do
        let(:arguments) { %w[ichi ni san] }
        let(:keywords)  { { one: 1, two: 2, three: 3 } }
        let(:result) do
          command.call(
            arguments: arguments,
            keywords:  keywords,
            strategy:  strategy
          )
        end
        let(:expected_error) do
          contract = Cuprum::Collections::Queries::ParseBlock::CONTRACT
          errors   = contract.errors_for(
            arguments: arguments,
            keywords:  keywords
          )

          Cuprum::Collections::Errors::InvalidQuery.new(
            errors:   errors,
            strategy: strategy
          )
        end

        it 'should return a failing result' do
          expect(result)
            .to be_a_failing_result
            .with_error(expected_error)
        end
      end
    end
  end
end
