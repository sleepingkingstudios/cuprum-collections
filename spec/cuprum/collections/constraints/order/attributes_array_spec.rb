# frozen_string_literal: true

require 'cuprum/collections/constraints/order/attributes_array'

require 'support/examples/constraint_examples'

RSpec.describe Cuprum::Collections::Constraints::Order::AttributesArray do
  include Spec::Support::Examples::ConstraintExamples

  subject(:constraint) { described_class.new(**constructor_options) }

  let(:constructor_options) { {} }
  let(:expected_options) do
    {
      allow_empty:   true,
      expected_type: Array,
      item_type:     Cuprum::Collections::Constraints::AttributeName.instance,
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

  include_examples 'should implement the Constraint interface'

  include_examples 'should implement the Constraint methods'

  describe '#match' do
    let(:match_method) { :match }
    let(:expected_errors) do
      {
        data: {
          allow_empty: true,
          required:    true,
          type:        Array
        },
        type: Stannum::Constraints::Type::TYPE
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

    describe 'with an empty array' do
      let(:actual) { [] }

      include_examples 'should match the constraint'
    end

    describe 'with an array with nil' do
      let(:actual) { [nil] }
      let(:expected_errors) do
        {
          path: [0],
          type: Stannum::Constraints::Presence::TYPE
        }
      end

      include_examples 'should not match the constraint'
    end

    describe 'with an array with an object' do
      let(:actual) { [Object.new.freeze] }
      let(:expected_errors) do
        {
          path: [0],
          type: Cuprum::Collections::Constraints::AttributeName::TYPE
        }
      end

      include_examples 'should not match the constraint'
    end

    describe 'with an array with an empty string' do
      let(:actual) { [''] }
      let(:expected_errors) do
        {
          path: [0],
          type: Stannum::Constraints::Presence::TYPE
        }
      end

      include_examples 'should not match the constraint'
    end

    describe 'with an array with a string' do
      let(:actual) { %w[title] }

      include_examples 'should match the constraint'
    end

    describe 'with an array with many strings' do
      let(:actual) { %w[author genre title] }

      include_examples 'should match the constraint'
    end

    describe 'with an array with an empty symbol' do
      let(:actual) { [:''] }
      let(:expected_errors) do
        {
          path: [0],
          type: Stannum::Constraints::Presence::TYPE
        }
      end

      include_examples 'should not match the constraint'
    end

    describe 'with an array with a symbol' do
      let(:actual) { %i[title] }

      include_examples 'should match the constraint'
    end

    describe 'with an array with many symbols' do
      let(:actual) { %i[author genre title] }

      include_examples 'should match the constraint'
    end

    context 'when initialized with allow_empty: false' do
      let(:constructor_options) { super().merge(allow_empty: false) }

      describe 'with an empty Array' do
        let(:actual) { [] }
        let(:expected_errors) do
          {
            data: {
              allow_empty: false,
              required:    true,
              type:        Array
            },
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
        data: {
          allow_empty: true,
          required:    true,
          type:        Array
        },
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

    describe 'with an array with an empty string' do
      let(:actual) { [''] }

      include_examples 'should not match the constraint'
    end

    describe 'with an array with a string' do
      let(:actual) { %w[title] }

      include_examples 'should not match the constraint'
    end

    describe 'with an array with many strings' do
      let(:actual) { %w[author genre title] }

      include_examples 'should not match the constraint'
    end

    describe 'with an array with an empty symbol' do
      let(:actual) { [:''] }

      include_examples 'should not match the constraint'
    end

    describe 'with an array with a symbol' do
      let(:actual) { %i[title] }

      include_examples 'should not match the constraint'
    end

    describe 'with an array with many symbols' do
      let(:actual) { %i[author genre title] }

      include_examples 'should not match the constraint'
    end

    context 'when initialized with allow_empty: false' do
      let(:constructor_options) { super().merge(allow_empty: false) }
      let(:expected_errors) do
        {
          data: {
            allow_empty: false,
            required:    true,
            type:        Array
          },
          type: Stannum::Constraints::Type::NEGATED_TYPE
        }
      end

      describe 'with an empty Array' do
        let(:actual) { [] }

        include_examples 'should not match the constraint'
      end
    end
  end
end
