# frozen_string_literal: true

require 'cuprum/collections/constraints/order/attributes_hash'

require 'support/examples/constraint_examples'

RSpec.describe Cuprum::Collections::Constraints::Order::AttributesHash do
  include Spec::Support::Examples::ConstraintExamples

  subject(:constraint) { described_class.new(**constructor_options) }

  let(:constructor_options) { {} }
  let(:expected_options) do
    {
      allow_empty:   true,
      expected_type: Hash,
      key_type:      Cuprum::Collections::Constraints::AttributeName.instance,
      value_type:    Cuprum::Collections::Constraints::Order::SortDirection
        .instance,
      required:      true
    }
  end

  describe '::NEGATED_TYPE' do
    include_examples 'should define frozen constant',
      :NEGATED_TYPE,
      Stannum::Constraints::Type::NEGATED_TYPE
  end

  describe '::TYPE' do
    include_examples 'should define frozen constant',
      :TYPE,
      Stannum::Constraints::Type::TYPE
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

  describe '.non_empty_instance' do
    let(:cached)           { described_class.non_empty_instance }
    let(:expected_options) { super().merge(allow_empty: false) }

    it 'should define the class method' do
      expect(described_class)
        .to respond_to(:non_empty_instance)
        .with(0).arguments
    end

    it { expect(described_class.non_empty_instance).to be_a described_class }

    it { expect(described_class.non_empty_instance).to be cached }

    it 'should set the options' do
      expect(described_class.non_empty_instance.options)
        .to be == expected_options
    end
  end

  include_examples 'should implement the Constraint interface'

  include_examples 'should implement the Constraint methods'

  describe '#match' do
    let(:match_method) { :match }
    let(:expected_errors) do
      {
        data: { allow_empty: true, required: true, type: Hash },
        type: Stannum::Constraints::Type::TYPE
      }
    end
    let(:sort_directions) do
      [
        'asc',
        'ascending',
        'desc',
        'descending',
        :asc,
        :ascending,
        :desc,
        :descending
      ]
    end

    describe 'with nil' do
      let(:actual) { nil }

      include_examples 'should not match the constraint'
    end

    describe 'with an object' do
      let(:actual) { Object.new.freeze }

      include_examples 'should not match the constraint'
    end

    describe 'with an empty hash' do
      let(:actual) { {} }

      include_examples 'should match the constraint'
    end

    describe 'with a hash with an invalid key' do
      let(:object) { Object.new.freeze }
      let(:actual) { { object => :asc } }
      let(:expected_errors) do
        {
          path: [:keys, object.inspect],
          type: Cuprum::Collections::Constraints::AttributeName::TYPE
        }
      end

      include_examples 'should not match the constraint'
    end

    describe 'with a hash with string keys and invalid values' do
      let(:actual) { { 'title' => 'random' } }
      let(:expected_errors) do
        {
          data: { values: sort_directions },
          path: %w[title],
          type: Cuprum::Collections::Constraints::Order::SortDirection::TYPE
        }
      end

      include_examples 'should not match the constraint'
    end

    describe 'with a hash with symbol keys and invalid values' do
      let(:actual) { { title: 'random' } }
      let(:expected_errors) do
        {
          data: { values: sort_directions },
          path: %i[title],
          type: Cuprum::Collections::Constraints::Order::SortDirection::TYPE
        }
      end

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

    context 'when initialized with allow_empty: false' do
      let(:constructor_options) { super().merge(allow_empty: false) }

      describe 'with an empty hash' do
        let(:actual) { {} }
        let(:expected_errors) do
          {
            data: { allow_empty: false, required: true, type: Hash },
            type: Stannum::Constraints::Presence::TYPE
          }
        end

        include_examples 'should not match the constraint'
      end
    end
  end

  describe '#negated_match' do
    let(:match_method) { :negated_match }
    let(:expected_errors) do
      {
        data: { allow_empty: true, required: true, type: Hash },
        type: Stannum::Constraints::Type::NEGATED_TYPE
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

    describe 'with an empty hash' do
      let(:actual) { {} }

      include_examples 'should not match the constraint'
    end

    describe 'with a hash with an invalid key' do
      let(:object) { Object.new.freeze }
      let(:actual) { { object => :asc } }

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

      include_examples 'should not match the constraint'
    end

    describe 'with a hash with symbol keys and valid values' do
      let(:actual) { { title: :asc } }

      include_examples 'should not match the constraint'
    end

    context 'when initialized with allow_empty: false' do
      let(:constructor_options) { super().merge(allow_empty: false) }

      describe 'with an empty hash' do
        let(:actual) { {} }
        let(:expected_errors) do
          {
            data: { allow_empty: false, required: true, type: Hash },
            type: Stannum::Constraints::Type::NEGATED_TYPE
          }
        end

        include_examples 'should not match the constraint'
      end
    end
  end
end
