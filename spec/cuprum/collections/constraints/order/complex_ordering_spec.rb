# frozen_string_literal: true

require 'cuprum/collections/constraints/order/complex_ordering'

require 'support/examples/constraint_examples'

RSpec.describe Cuprum::Collections::Constraints::Order::ComplexOrdering do
  include Spec::Support::Examples::ConstraintExamples

  subject(:constraint) { described_class.new(**constructor_options) }

  let(:constructor_options) { {} }
  let(:expected_options)    { {} }

  describe '::NEGATED_TYPE' do
    include_examples 'should define frozen constant',
      :NEGATED_TYPE,
      Stannum::Constraint::NEGATED_TYPE
  end

  describe '::TYPE' do
    include_examples 'should define frozen constant',
      :TYPE,
      Stannum::Constraint::TYPE
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

    it { expect(described_class.instance.options).to be == expected_options }
  end

  include_examples 'should implement the Constraint interface'

  include_examples 'should implement the Constraint methods'

  describe '#match' do
    let(:match_method) { :match }
    let(:expected_errors) do
      {
        data: {},
        type: described_class::TYPE
      }
    end

    describe 'with nil' do
      let(:actual) { nil }

      include_examples 'should not match the constraint'
    end

    describe 'with an object' do
      let(:actual) { Object.new.freeze }

      include_examples 'should not match the constraint'
    end

    describe 'with a string' do
      let(:actual) { 'string' }

      include_examples 'should not match the constraint'
    end

    describe 'with a symbol' do
      let(:actual) { :symbol }

      include_examples 'should not match the constraint'
    end

    describe 'with an empty array' do
      let(:actual) { [] }

      include_examples 'should not match the constraint'
    end

    describe 'with an array of invalid items' do
      let(:actual) { [nil, :title] }

      include_examples 'should not match the constraint'
    end

    describe 'with an array of invalid items and an empty hash' do
      let(:actual) { [nil, :title, {}] }

      include_examples 'should not match the constraint'
    end

    describe 'with an array of attribute names' do
      let(:actual) { %i[title author] }

      include_examples 'should not match the constraint'
    end

    describe 'with an array of attribute names and an empty hash' do
      let(:actual) { %i[title author] + [{}] }

      include_examples 'should match the constraint'
    end

    describe 'with an array of attribute names and an ordering hash' do
      let(:actual) { %i[title author] + [{ published_at: :asc }] }

      include_examples 'should match the constraint'
    end

    describe 'with an array with an empty hash' do
      let(:actual) { [{}] }

      include_examples 'should match the constraint'
    end

    describe 'with an array with an ordering hash' do
      let(:actual) { [{ published_at: :asc }] }

      include_examples 'should match the constraint'
    end

    describe 'with an empty hash' do
      let(:actual) { {} }

      include_examples 'should not match the constraint'
    end

    describe 'with an ordering hash' do
      let(:actual) { { published_at: :asc } }

      include_examples 'should not match the constraint'
    end
  end

  describe '#negated_match' do
    let(:match_method) { :negated_match }
    let(:expected_errors) do
      {
        data: {},
        type: described_class::NEGATED_TYPE
      }
    end

    describe 'with nil' do
      let(:actual) { nil }

      include_examples 'should match the constraint'
    end

    describe 'with an object' do
      let(:actual) { Object.new.freeze }

      include_examples 'should match the constraint'
    end

    describe 'with a string' do
      let(:actual) { 'string' }

      include_examples 'should match the constraint'
    end

    describe 'with a symbol' do
      let(:actual) { :symbol }

      include_examples 'should match the constraint'
    end

    describe 'with an empty array' do
      let(:actual) { [] }

      include_examples 'should match the constraint'
    end

    describe 'with an array of invalid items' do
      let(:actual) { [nil, :title] }

      include_examples 'should match the constraint'
    end

    describe 'with an array of invalid items and an empty hash' do
      let(:actual) { [nil, :title, {}] }

      include_examples 'should match the constraint'
    end

    describe 'with an array of attribute names' do
      let(:actual) { %i[title author] }

      include_examples 'should match the constraint'
    end

    describe 'with an array of attribute names and an empty hash' do
      let(:actual) { %i[title author] + [{}] }

      include_examples 'should not match the constraint'
    end

    describe 'with an array of attribute names and an ordering hash' do
      let(:actual) { %i[title author] + [{ published_at: :asc }] }

      include_examples 'should not match the constraint'
    end

    describe 'with an array with an empty hash' do
      let(:actual) { [{}] }

      include_examples 'should not match the constraint'
    end

    describe 'with an array with an ordering hash' do
      let(:actual) { [{ published_at: :asc }] }

      include_examples 'should not match the constraint'
    end

    describe 'with an empty hash' do
      let(:actual) { {} }

      include_examples 'should match the constraint'
    end

    describe 'with an ordering hash' do
      let(:actual) { { published_at: :asc } }

      include_examples 'should match the constraint'
    end
  end
end
