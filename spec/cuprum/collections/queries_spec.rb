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
        NOT_NULL:                 :not_null,
        NOT_ONE_OF:               :not_one_of,
        NULL:                     :null,
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

    describe '::GREATER_THAN' do
      it 'should store the value' do
        expect(described_class::Operators::GREATER_THAN).to be :greater_than
      end
    end

    describe '::GREATER_THAN_OR_EQUAL_TO' do
      it 'should store the value' do
        expect(described_class::Operators::GREATER_THAN_OR_EQUAL_TO)
          .to be :greater_than_or_equal_to
      end
    end

    describe '::LESS_THAN' do
      it 'should store the value' do
        expect(described_class::Operators::LESS_THAN).to be :less_than
      end
    end

    describe '::LESS_THAN_OR_EQUAL_TO' do
      it 'should store the value' do
        expect(described_class::Operators::LESS_THAN_OR_EQUAL_TO)
          .to be :less_than_or_equal_to
      end
    end

    describe '::NOT_EQUAL' do
      it 'should store the value' do
        expect(described_class::Operators::NOT_EQUAL).to be :not_equal
      end
    end

    describe '::NOT_NULL' do
      it 'should store the value' do
        expect(described_class::Operators::NOT_NULL).to be :not_null
      end
    end

    describe '::NOT_ONE_OF' do
      it 'should store the value' do
        expect(described_class::Operators::NOT_ONE_OF).to be :not_one_of
      end
    end

    describe '::NULL' do
      it 'should store the value' do
        expect(described_class::Operators::NULL).to be :null
      end
    end

    describe '::ONE_OF' do
      it 'should store the value' do
        expect(described_class::Operators::ONE_OF).to be :one_of
      end
    end
  end

  describe '::UninvertibleOperatorException' do
    include_examples 'should define constant',
      :UninvertibleOperatorException,
      -> { be_a(Class).and(be < StandardError) }
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

  describe '::INVERTIBLE_OPERATORS' do
    let(:expected) do
      op = described_class::Operators

      {
        op::EQUAL                    => op::NOT_EQUAL,
        op::GREATER_THAN             => op::LESS_THAN_OR_EQUAL_TO,
        op::GREATER_THAN_OR_EQUAL_TO => op::LESS_THAN,
        op::LESS_THAN                => op::GREATER_THAN_OR_EQUAL_TO,
        op::LESS_THAN_OR_EQUAL_TO    => op::GREATER_THAN,
        op::NOT_EQUAL                => op::EQUAL,
        op::NOT_NULL                 => op::NULL,
        op::NOT_ONE_OF               => op::ONE_OF,
        op::NULL                     => op::NOT_NULL,
        op::ONE_OF                   => op::NOT_ONE_OF
      }
    end

    include_examples 'should define immutable constant',
      :INVERTIBLE_OPERATORS,
      -> { be == expected }
  end

  describe '::VALID_OPERATORS' do
    let(:expected_operators) { described_class::Operators.values }

    include_examples 'should define immutable constant', :VALID_OPERATORS

    it { expect(described_class::VALID_OPERATORS).to be_a Set }

    it 'should contain the expected operators' do
      expect(described_class::VALID_OPERATORS)
        .to match_array(expected_operators)
    end
  end
end
