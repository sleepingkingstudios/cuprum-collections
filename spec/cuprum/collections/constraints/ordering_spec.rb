# frozen_string_literal: true

require 'cuprum/collections/constraints/ordering'

require 'support/examples/constraint_examples'
require 'support/examples/optional_examples'

RSpec.describe Cuprum::Collections::Constraints::Ordering do
  include Spec::Support::Examples::ConstraintExamples
  include Spec::Support::Examples::OptionalExamples

  subject(:constraint) { described_class.new(**constructor_options) }

  let(:expected_constraints) do
    [
      Cuprum::Collections::Constraints::AttributeName.instance,
      Cuprum::Collections::Constraints::Order::AttributesArray.instance,
      Cuprum::Collections::Constraints::Order::AttributesHash.instance,
      Cuprum::Collections::Constraints::Order::ComplexOrdering.instance
    ]
  end
  let(:constructor_options) { {} }
  let(:expected_options) do
    {
      expected_constraints: expected_constraints,
      required:             true
    }
  end

  describe '::NEGATED_TYPE' do
    include_examples 'should define frozen constant',
      :NEGATED_TYPE,
      'cuprum.collections.constraints.is_valid_ordering'
  end

  describe '::TYPE' do
    include_examples 'should define frozen constant',
      :TYPE,
      'cuprum.collections.constraints.is_not_valid_ordering'
  end

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:optional, :required)
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

  include_examples 'should implement the Optional interface'

  include_examples 'should implement the Optional methods'

  describe '#match' do
    let(:match_method) { :match }
    let(:expected_errors) do
      {
        data: {},
        type: constraint.type
      }
    end
    let(:expected_messages) do
      expected_errors.merge(message: 'is not a valid sort order')
    end

    describe 'with nil' do
      let(:actual) { nil }

      include_examples 'should not match the constraint'
    end

    describe 'with an object' do
      let(:actual) { Object.new.freeze }

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

    describe 'with a string' do
      let(:actual) { 'title' }

      include_examples 'should match the constraint'
    end

    describe 'with an empty array' do
      let(:actual) { [] }

      include_examples 'should match the constraint'
    end

    describe 'with an array with nil' do
      let(:actual) { [nil] }

      include_examples 'should not match the constraint'
    end

    describe 'with an array with an object' do
      let(:actual) { [Object.new.freeze] }

      include_examples 'should not match the constraint'
    end

    describe 'with an array with a string' do
      let(:actual) { %w[title] }

      include_examples 'should match the constraint'
    end

    describe 'with an array with a symbol' do
      let(:actual) { %i[title] }

      include_examples 'should match the constraint'
    end

    describe 'with an array with many strings' do
      let(:actual) { %w[author genre title] }

      include_examples 'should match the constraint'
    end

    describe 'with an array with many symbols' do
      let(:actual) { %i[author genre title] }

      include_examples 'should match the constraint'
    end

    describe 'with an array with an empty hash' do
      let(:actual) { [{}] }

      include_examples 'should match the constraint'
    end

    describe 'with an array with an invalid hash' do
      let(:actual) { [{ title: nil }] }

      include_examples 'should not match the constraint'
    end

    describe 'with an array with a valid hash' do
      let(:actual) { [{ title: :asc, author: :desc }] }

      include_examples 'should match the constraint'
    end

    describe 'with an array with many strings and an empty hash' do
      let(:actual) { %w[author genre title] + [{}] }

      include_examples 'should match the constraint'
    end

    describe 'with an array with many strings and an invalid hash' do
      let(:actual) { %w[author genre title] + [{ title: nil }] }

      include_examples 'should not match the constraint'
    end

    describe 'with an array with many strings and a valid hash' do
      let(:actual) { %w[author genre title] + [{ title: :asc, author: :desc }] }

      include_examples 'should match the constraint'
    end

    describe 'with an array with many symbols and an empty hash' do
      let(:actual) { %i[author genre title] + [{}] }

      include_examples 'should match the constraint'
    end

    describe 'with an array with many symbols and an invalid hash' do
      let(:actual) { %i[author genre title] + [{ title: nil }] }

      include_examples 'should not match the constraint'
    end

    describe 'with an array with many symbols and a valid hash' do
      let(:actual) { %i[author genre title] + [{ title: :asc, author: :desc }] }

      include_examples 'should match the constraint'
    end

    describe 'with an empty hash' do
      let(:actual) { {} }

      include_examples 'should match the constraint'
    end

    describe 'with a hash with an invalid key' do
      let(:actual) { { Object.new.freeze => :asc } }

      include_examples 'should not match the constraint'
    end

    describe 'with a hash with string keys and invalid values' do
      let(:actual) { { 'title' => 'random' } }

      include_examples 'should not match the constraint'
    end

    describe 'with a hash with symbol keys and invalid values' do
      let(:actual) { { title: 'random' } }

      include_examples 'should not match the constraint'
    end

    describe 'with a hash with string keys and valid values' do
      let(:actual) { { 'title' => 'asc' } }

      include_examples 'should match the constraint'
    end

    describe 'with a hash with symbol keys and valid values' do
      let(:actual) { { title: :asc } }

      include_examples 'should match the constraint'
    end

    context 'when the constraint is optional' do
      let(:constructor_options) { super().merge(required: false) }

      describe 'with nil' do
        let(:actual) { nil }

        include_examples 'should match the constraint'
      end

      describe 'with a non-matching object' do
        let(:actual) { Object.new.freeze }

        include_examples 'should not match the constraint'
      end
    end
  end

  describe '#negated_match' do
    let(:match_method) { :negated_match }
    let(:expected_errors) do
      {
        data: {},
        type: constraint.negated_type
      }
    end
    let(:expected_messages) do
      expected_errors.merge(message: 'is a valid sort order')
    end

    describe 'with nil' do
      let(:actual) { nil }

      include_examples 'should match the constraint'
    end

    describe 'with an object' do
      let(:actual) { Object.new.freeze }

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

    describe 'with a string' do
      let(:actual) { 'title' }

      include_examples 'should not match the constraint'
    end

    describe 'with an empty array' do
      let(:actual) { [] }

      include_examples 'should not match the constraint'
    end

    describe 'with an array with nil' do
      let(:actual) { [nil] }

      include_examples 'should match the constraint'
    end

    describe 'with an array with an object' do
      let(:actual) { [Object.new.freeze] }

      include_examples 'should match the constraint'
    end

    describe 'with an array with a string' do
      let(:actual) { %w[title] }

      include_examples 'should not match the constraint'
    end

    describe 'with an array with a symbol' do
      let(:actual) { %i[title] }

      include_examples 'should not match the constraint'
    end

    describe 'with an array with many strings' do
      let(:actual) { %w[author genre title] }

      include_examples 'should not match the constraint'
    end

    describe 'with an array with many symbols' do
      let(:actual) { %i[author genre title] }

      include_examples 'should not match the constraint'
    end

    describe 'with an array with an empty hash' do
      let(:actual) { [{}] }

      include_examples 'should not match the constraint'
    end

    describe 'with an array with an invalid hash' do
      let(:actual) { [{ title: nil }] }

      include_examples 'should match the constraint'
    end

    describe 'with an array with a valid hash' do
      let(:actual) { [{ title: :asc, author: :desc }] }

      include_examples 'should not match the constraint'
    end

    describe 'with an array with many strings and an empty hash' do
      let(:actual) { %w[author genre title] + [{}] }

      include_examples 'should not match the constraint'
    end

    describe 'with an array with many strings and an invalid hash' do
      let(:actual) { %w[author genre title] + [{ title: nil }] }

      include_examples 'should match the constraint'
    end

    describe 'with an array with many strings and a valid hash' do
      let(:actual) { %w[author genre title] + [{ title: :asc, author: :desc }] }

      include_examples 'should not match the constraint'
    end

    describe 'with an array with many symbols and an empty hash' do
      let(:actual) { %i[author genre title] + [{}] }

      include_examples 'should not match the constraint'
    end

    describe 'with an array with many symbols and an invalid hash' do
      let(:actual) { %i[author genre title] + [{ title: nil }] }

      include_examples 'should match the constraint'
    end

    describe 'with an array with many symbols and a valid hash' do
      let(:actual) { %i[author genre title] + [{ title: :asc, author: :desc }] }

      include_examples 'should not match the constraint'
    end

    describe 'with an empty hash' do
      let(:actual) { {} }

      include_examples 'should not match the constraint'
    end

    describe 'with a hash with invalid key' do
      let(:actual) { { Object.new.freeze => :asc } }

      include_examples 'should match the constraint'
    end

    describe 'with a hash with string keys and invalid values' do
      let(:actual) { { 'title' => 'random' } }

      include_examples 'should match the constraint'
    end

    describe 'with a hash with symbol keys and invalid values' do
      let(:actual) { { title: 'random' } }

      include_examples 'should match the constraint'
    end

    describe 'with a hash with string keys and valid values' do
      let(:actual) { { 'title' => 'asc' } }

      include_examples 'should not match the constraint'
    end

    describe 'with a hash with symbol keys and valid values' do
      let(:actual) { { title: :asc } }

      include_examples 'should not match the constraint'
    end

    context 'when the constraint is optional' do
      let(:constructor_options) { super().merge(required: false) }

      describe 'with nil' do
        let(:actual) { nil }

        include_examples 'should not match the constraint'
      end

      describe 'with a non-matching object' do
        let(:actual) { Object.new.freeze }

        include_examples 'should match the constraint'
      end
    end
  end

  describe '#with_options' do
    let(:copy) { subject.with_options(**options) }

    describe 'with optional: false' do
      let(:options) { { optional: false } }

      it { expect(copy.options[:required]).to be true }
    end

    describe 'with optional: true' do
      let(:options) { { optional: true } }

      it { expect(copy.options[:required]).to be false }
    end

    describe 'with required: false' do
      let(:options) { { required: false } }

      it { expect(copy.options[:required]).to be false }
    end

    describe 'with required: true' do
      let(:options) { { required: true } }

      it { expect(copy.options[:required]).to be true }
    end
  end
end
