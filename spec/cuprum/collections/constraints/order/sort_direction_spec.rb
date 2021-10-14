# frozen_string_literal: true

require 'cuprum/collections/constraints/order/sort_direction'

require 'support/examples/constraint_examples'

RSpec.describe Cuprum::Collections::Constraints::Order::SortDirection do
  include Spec::Support::Examples::ConstraintExamples

  subject(:constraint) { described_class.new(**constructor_options) }

  let(:expected_values) do
    %w[asc ascending desc descending] + %i[asc ascending desc descending]
  end
  let(:constructor_options) { {} }
  let(:expected_options)    { { expected_values: expected_values } }

  describe '::NEGATED_TYPE' do
    include_examples 'should define frozen constant',
      :NEGATED_TYPE,
      'cuprum.collections.constraints.is_valid_sort_direction'
  end

  describe '::TYPE' do
    include_examples 'should define frozen constant',
      :TYPE,
      'cuprum.collections.constraints.is_not_valid_sort_direction'
  end

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_any_keywords
    end
  end

  describe '.instance' do
    let(:cached) { described_class.instance }

    it { expect(described_class).to respond_to(:instance).with(0).arguments }

    it { expect(described_class.instance).to be_a described_class }

    it { expect(described_class.instance).to be cached }
  end

  include_examples 'should implement the Constraint interface'

  include_examples 'should implement the Constraint methods'

  describe '#expected_values' do
    include_examples 'should have reader',
      :expected_values,
      -> { expected_values }
  end

  describe '#match' do
    let(:match_method) { :match }
    let(:expected_errors) do
      {
        data: { values: expected_values },
        type: constraint.type
      }
    end
    let(:expected_messages) do
      expected_errors.merge(message: 'is not a valid sort direction')
    end

    describe 'with nil' do
      let(:actual) { nil }

      include_examples 'should not match the constraint'
    end

    describe 'with an object' do
      let(:actual) { Object.new }

      include_examples 'should not match the constraint'
    end

    describe 'with an empty string' do
      let(:actual) { '' }

      include_examples 'should not match the constraint'
    end

    describe 'with an empty symbol' do
      let(:actual) { :'' }

      include_examples 'should not match the constraint'
    end

    describe 'with a non-matching string' do
      let(:actual) { 'random' }

      include_examples 'should not match the constraint'
    end

    describe 'with a non-matching symbol' do
      let(:actual) { :random }

      include_examples 'should not match the constraint'
    end

    describe 'with a matching string' do
      let(:actual) { 'asc' }

      include_examples 'should match the constraint'
    end

    describe 'with a matching symbol' do
      let(:actual) { :asc }

      include_examples 'should match the constraint'
    end
  end

  describe '#negated_match' do
    let(:match_method) { :negated_match }
    let(:expected_errors) do
      {
        data: { values: expected_values },
        type: constraint.negated_type
      }
    end
    let(:expected_messages) do
      expected_errors.merge(message: 'is a valid sort direction')
    end

    describe 'with an object' do
      let(:actual) { Object.new }

      include_examples 'should match the constraint'
    end

    describe 'with an empty string' do
      let(:actual) { '' }

      include_examples 'should match the constraint'
    end

    describe 'with an empty symbol' do
      let(:actual) { :'' }

      include_examples 'should match the constraint'
    end

    describe 'with a non-matching string' do
      let(:actual) { 'random' }

      include_examples 'should match the constraint'
    end

    describe 'with a non-matching symbol' do
      let(:actual) { :random }

      include_examples 'should match the constraint'
    end

    describe 'with a matching string' do
      let(:actual) { 'asc' }

      include_examples 'should not match the constraint'
    end

    describe 'with a matching symbol' do
      let(:actual) { :asc }

      include_examples 'should not match the constraint'
    end
  end
end
