# frozen_string_literal: true

require 'cuprum/collections/queries'

RSpec.describe Cuprum::Collections::Queries do
  describe '::Operators' do
    let(:expected_operators) do
      {
        EQUAL:                    :equal,
        GREATER_THAN:             :greater_than,
        GREATER_THAN_OR_EQUAL_TO: :greater_than_or_equal_to,
        LESS_THAN:                :less_than,
        LESS_THAN_OR_EQUAL_TO:    :less_than_or_equal_to,
        NOT_EQUAL:                :not_equal,
        NOT_ONE_OF:               :not_one_of,
        ONE_OF:                   :one_of
      }
    end

    include_examples 'should define immutable constant', :Operators

    it 'should enumerate the operators' do
      expect(described_class::Operators.all).to deep_match expected_operators
    end

    describe '::EQUAL' do
      it 'should store the value' do
        expect(described_class::Operators::EQUAL).to be :equal
      end
    end

    describe '::NOT_EQUAL' do
      it 'should store the value' do
        expect(described_class::Operators::NOT_EQUAL).to be :not_equal
      end
    end

    describe '::NOT_ONE_OF' do
      it 'should store the value' do
        expect(described_class::Operators::NOT_ONE_OF).to be :not_one_of
      end
    end

    describe '::ONE_OF' do
      it 'should store the value' do
        expect(described_class::Operators::ONE_OF).to be :one_of
      end
    end
  end

  describe '::VALID_OPERATORS' do
    let(:expected_operators) { described_class::Operators.values }

    include_examples 'should define immutable constant', :VALID_OPERATORS

    it { expect(described_class::VALID_OPERATORS).to be_a Set }

    it 'should contain the expected operators' do
      expect(described_class::VALID_OPERATORS)
        .to contain_exactly(*expected_operators)
    end
  end
end
