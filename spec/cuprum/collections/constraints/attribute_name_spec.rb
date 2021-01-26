# frozen_string_literal: true

require 'cuprum/collections/constraints/attribute_name'

require 'support/examples/constraint_examples'

RSpec.describe Cuprum::Collections::Constraints::AttributeName do
  include Spec::Support::Examples::ConstraintExamples

  subject(:constraint) { described_class.new(**constructor_options) }

  let(:constructor_options) { {} }
  let(:expected_options)    { {} }

  describe '::NEGATED_TYPE' do
    include_examples 'should define frozen constant',
      :NEGATED_TYPE,
      'cuprum.collections.constraints.is_valid_attribute_name'
  end

  describe '::TYPE' do
    include_examples 'should define frozen constant',
      :TYPE,
      'cuprum.collections.constraints.is_not_valid_attribute_name'
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
    let(:match_method)    { :match }
    let(:expected_errors) { { type: Stannum::Constraints::Presence::TYPE } }

    describe 'with nil' do
      let(:actual) { nil }

      include_examples 'should not match the constraint'
    end

    describe 'with an object' do
      let(:actual) { Object.new.freeze }
      let(:expected_errors) do
        { type: constraint.type }
      end

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

    describe 'with a symbol' do
      let(:actual) { :title }

      include_examples 'should match the constraint'
    end
  end

  describe '#negated_match' do
    let(:match_method)    { :negated_match }
    let(:expected_errors) { { type: constraint.negated_type } }

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

    describe 'with a symbol' do
      let(:actual) { :title }

      include_examples 'should not match the constraint'
    end
  end
end
