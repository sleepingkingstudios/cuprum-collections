# frozen_string_literal: true

require 'cuprum/collections/queries'

RSpec.describe Cuprum::Collections::Queries do
  describe '::Operators' do
    let(:expected_operators) do
      {
        EQUAL:     :eq,
        NOT_EQUAL: :ne
      }
    end

    include_examples 'should define immutable constant', :Operators

    it 'should enumerate the operators' do
      expect(described_class::Operators.all).to be == expected_operators
    end

    describe '::EQUAL' do
      it 'should store the value' do
        expect(described_class::Operators::EQUAL).to be :eq
      end
    end

    describe '::NOT_EQUAL' do
      it 'should store the value' do
        expect(described_class::Operators::NOT_EQUAL).to be :ne
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
