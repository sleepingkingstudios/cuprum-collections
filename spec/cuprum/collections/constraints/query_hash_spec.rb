# frozen_string_literal: true

require 'cuprum/collections/constraints/query_hash'

require 'support/examples/constraint_examples'

RSpec.describe Cuprum::Collections::Constraints::QueryHash do
  include Spec::Support::Examples::ConstraintExamples

  subject(:constraint) { described_class.new(**constructor_options) }

  let(:constructor_options) { {} }
  let(:expected_options) do
    {
      allow_empty:   true,
      key_type:      be_a(Cuprum::Collections::Constraints::AttributeName),
      expected_type: Hash,
      required:      true,
      value_type:    nil
    }
  end

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_any_keywords
    end
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
          type:        Hash
        },
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

    describe 'with an empty Hash' do
      let(:actual) { {} }

      include_examples 'should match the constraint'
    end

    describe 'with a Hash with object key' do
      let(:actual) { { nil => 'value' } }
      let(:expected_errors) do
        {
          data: {},
          path: [:keys, 'nil'],
          type: Stannum::Constraints::Presence::TYPE
        }
      end

      include_examples 'should not match the constraint'
    end

    describe 'with a Hash with empty string key' do
      let(:actual) { { '' => 'value' } }
      let(:expected_errors) do
        {
          data: {},
          path: [:keys, ''],
          type: Stannum::Constraints::Presence::TYPE
        }
      end

      include_examples 'should not match the constraint'
    end

    describe 'with a Hash with empty symbol key' do
      let(:actual) { { '': 'value' } }
      let(:expected_errors) do
        {
          data: {},
          path: [:keys, :''],
          type: Stannum::Constraints::Presence::TYPE
        }
      end

      include_examples 'should not match the constraint'
    end

    describe 'with a Hash with string key' do
      let(:actual) { { 'key' => 'value' } }

      include_examples 'should match the constraint'
    end

    describe 'with a Hash with symbol key' do
      let(:actual) { { key: 'value' } }

      include_examples 'should match the constraint'
    end
  end

  describe '#negated_match' do
    let(:match_method) { :negated_match }
    let(:expected_errors) do
      {
        data: {
          allow_empty: true,
          required:    true,
          type:        Hash
        },
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

    describe 'with an empty Hash' do
      let(:actual) { {} }

      include_examples 'should not match the constraint'
    end

    describe 'with a Hash with object key' do
      let(:actual) { { nil => 'value' } }

      include_examples 'should not match the constraint'
    end

    describe 'with a Hash with empty string key' do
      let(:actual) { { '' => 'value' } }

      include_examples 'should not match the constraint'
    end

    describe 'with a Hash with empty symbol key' do
      let(:actual) { { '': 'value' } }

      include_examples 'should not match the constraint'
    end

    describe 'with a Hash with string key' do
      let(:actual) { { 'key' => 'value' } }

      include_examples 'should not match the constraint'
    end

    describe 'with a Hash with symbol key' do
      let(:actual) { { key: 'value' } }

      include_examples 'should not match the constraint'
    end
  end
end
