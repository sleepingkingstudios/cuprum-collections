# frozen_string_literal: true

require 'cuprum/collections/constraints/ordering'

require 'support/examples/constraint_examples'
require 'support/examples/optional_examples'

RSpec.describe Cuprum::Collections::Constraints::Ordering do
  include Spec::Support::Examples::ConstraintExamples
  include Spec::Support::Examples::OptionalExamples

  subject(:constraint) { described_class.new(**constructor_options) }

  let(:expected_constraints) do
    sort_direction_constraint =
      Cuprum::Collections::Constraints::Order::SortDirection.instance
    attribute_name_constraint =
      Cuprum::Collections::Constraints::AttributeName.instance
    attributes_array_constraint =
      Cuprum::Collections::Constraints::Order::AttributesArray
        .non_empty_instance
    attributes_hash_constraint =
      Stannum::Constraints::Types::HashType.new(
        allow_empty: false,
        key_type:    attribute_name_constraint,
        value_type:  sort_direction_constraint
      )

    [
      attribute_name_constraint,
      attributes_array_constraint,
      attributes_hash_constraint
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

  include_examples 'should implement the Constraint interface'

  include_examples 'should implement the Constraint methods'

  include_examples 'should implement the Optional interface'

  include_examples 'should implement the Optional methods'

  describe '#match' do
    let(:match_method) { :match }
    let(:expected_values) do
      [
        {
          options: {},
          type:    Cuprum::Collections::Constraints::AttributeName::TYPE
        },
        {
          options: {
            allow_empty:   false,
            expected_type: Array,
            item_type:     an_instance_of(
              Cuprum::Collections::Constraints::AttributeName
            ),
            required:      true
          },
          type:    Stannum::Constraints::Type::TYPE
        },
        {
          options: {
            allow_empty:   false,
            expected_type: Hash,
            key_type:      an_instance_of(
              Cuprum::Collections::Constraints::AttributeName
            ),
            required:      true,
            value_type:    an_instance_of(
              Cuprum::Collections::Constraints::Order::SortDirection
            )
          },
          type:    Stannum::Constraints::Type::TYPE
        }
      ]
    end
    let(:expected_errors) do
      {
        data: { constraints: expected_values },
        type: constraint.type
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

      include_examples 'should not match the constraint'
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

    describe 'with an empty hash' do
      let(:actual) { {} }

      include_examples 'should not match the constraint'
    end

    describe 'with a hash with invalid key' do
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
    let(:expected_values) do
      negated_attribute_type =
        Cuprum::Collections::Constraints::AttributeName::NEGATED_TYPE

      [
        {
          negated_type: negated_attribute_type,
          options:      {}
        },
        {
          negated_type: Stannum::Constraints::Type::NEGATED_TYPE,
          options:      {
            allow_empty:   false,
            expected_type: Array,
            item_type:     an_instance_of(
              Cuprum::Collections::Constraints::AttributeName
            ),
            required:      true
          }
        },
        {
          negated_type: Stannum::Constraints::Type::NEGATED_TYPE,
          options:      {
            allow_empty:   false,
            expected_type: Hash,
            key_type:      an_instance_of(
              Cuprum::Collections::Constraints::AttributeName
            ),
            required:      true,
            value_type:    an_instance_of(
              Cuprum::Collections::Constraints::Order::SortDirection
            )
          }
        }
      ]
    end
    let(:expected_errors) do
      {
        data: { constraints: expected_values },
        type: constraint.negated_type
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

      include_examples 'should match the constraint'
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

    describe 'with an empty hash' do
      let(:actual) { {} }

      include_examples 'should match the constraint'
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
