# frozen_string_literal: true

require 'cuprum/collections/scope'
require 'cuprum/collections/rspec/deferred/scopes/criteria_examples'
require 'cuprum/collections/rspec/deferred/scopes/parser_examples'

RSpec.describe Cuprum::Collections::Scope do
  include Cuprum::Collections::RSpec::Deferred::Scopes::CriteriaExamples
  include Cuprum::Collections::RSpec::Deferred::Scopes::ParserExamples

  subject(:scope) do
    described_class.new(
      *constructor_args,
      **constructor_options,
      &constructor_block
    )
  end

  let(:constructor_args)    { [] }
  let(:constructor_options) { {} }
  let(:constructor_block) do
    expected = criteria

    lambda do |scope|
      expected.to_h do |(attribute, operator, value)|
        [attribute, scope.send(operator, value)]
      end
    end
  end

  describe '.new' do
    def parse_criteria(...)
      described_class.new(...).criteria
    end

    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0..1).arguments
        .and_a_block
    end

    include_deferred 'should parse Scope criteria'
  end

  include_deferred 'should implement the CriteriaScope methods',
    abstract:            true,
    ignore_uninvertible: true,
    skip_constructor:    true,
    skip_equality:       true

  describe '#==' do
    describe 'with a scope with the same class' do
      let(:other) { described_class.new(&other_block) }

      describe 'with empty criteria' do
        let(:other_block) { -> { {} } }

        it { expect(scope == other).to be true }
      end

      describe 'with non-matching criteria' do
        let(:other_block) { -> { { 'ok' => true } } }

        it { expect(scope == other).to be false }
      end

      context 'when the scope has criteria' do
        let(:constructor_block) do
          -> { { 'title' => 'The Word for World is Forest' } }
        end

        describe 'with empty criteria' do
          let(:other_block) { -> { {} } }

          it { expect(scope == other).to be false }
        end

        describe 'with non-matching criteria' do
          let(:other_block) { -> { { 'ok' => true } } }

          it { expect(scope == other).to be false }
        end

        describe 'with matching criteria' do
          let(:other_block) { constructor_block }

          it { expect(scope == other).to be true }
        end
      end
    end

    describe 'with a scope with the same type' do
      let(:other) { Spec::CustomScope.new(criteria: other_criteria) }

      example_class 'Spec::CustomScope',
        Cuprum::Collections::Scopes::Base \
      do |klass|
        klass.include Cuprum::Collections::Scopes::Criteria
      end

      describe 'with empty criteria' do
        let(:other_criteria) { [] }

        it { expect(scope == other).to be true }
      end

      describe 'with non-matching criteria' do
        let(:other_criteria) do
          operators = Cuprum::Collections::Queries::Operators

          [
            [
              'ok',
              operators::EQUAL,
              true
            ]
          ]
        end

        it { expect(scope == other).to be false }
      end

      context 'when the scope has criteria' do
        let(:constructor_block) do
          -> { { 'title' => 'The Word for World is Forest' } }
        end

        describe 'with empty criteria' do
          let(:other_criteria) { [] }

          it { expect(scope == other).to be false }
        end

        describe 'with non-matching criteria' do
          let(:other_criteria) do
            operators = Cuprum::Collections::Queries::Operators

            [
              [
                'ok',
                operators::EQUAL,
                true
              ]
            ]
          end

          it { expect(scope == other).to be false }
        end

        describe 'with matching criteria' do
          let(:other_criteria) { scope.criteria }

          it { expect(scope == other).to be true }
        end
      end
    end
  end
end
