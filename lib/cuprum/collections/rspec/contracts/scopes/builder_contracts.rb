# frozen_string_literal: true

require 'cuprum/collections/queries'
require 'cuprum/collections/rspec/contracts/scopes'
require 'cuprum/collections/rspec/contracts/scopes/criteria_contracts'
require 'cuprum/collections/scopes/conjunction_scope'
require 'cuprum/collections/scopes/criteria_scope'
require 'cuprum/collections/scopes/disjunction_scope'
require 'cuprum/collections/scopes/negation_scope'

module Cuprum::Collections::RSpec::Contracts::Scopes
  # Contracts for asserting on scope builder objects.
  module BuilderContracts
    include Cuprum::Collections::RSpec::Contracts::Scopes::CriteriaContracts

    # Contract validating the behavior of a scope builder implementation.
    module ShouldBeAScopeBuilderContract
      extend RSpec::SleepingKingStudios::Contract

      # @!method apply(example_group, abstract: false, **options)
      #   Adds the contract to the example group.
      #
      #   @param example_group [RSpec::Core::ExampleGroup] the example group to
      #     which the contract is applied.
      #   @param abstract [Boolean] if true, the builder is abstract and does
      #     not define scope classes. Defaults to false.
      #   @param options [Hash] additional options for the contract.
      #
      #   @option options conjunction_class [Class] the class for returned
      #     logical AND scopes. Ignored if :abstract is true.
      #   @option options criteria_class [Class] the class for returned criteria
      #     scopes.Ignored if :abstract is true.
      #   @option options disjunction_class [Class] the class for returned
      #     logical OR scopes. Ignored if :abstract is true.
      #   @option options negation_class [Class] the class for returned logical
      #     NAND scopes. Ignored if :abstract is true.
      contract do |abstract: false, **contract_options|
        conjunction_scope_class = contract_options[:conjunction_class]
        criteria_scope_class    = contract_options[:criteria_class]
        disjunction_scope_class = contract_options[:disjunction_class]
        negation_scope_class    = contract_options[:negation_class]

        shared_examples 'should build a conjunction scope' do
          let(:scope) { build_container(scopes: scopes) }

          # :nocov:
          unless conjunction_scope_class
            pending '(must specify :conjunction_class option)'

            next
          end
          # :nocov:

          describe 'with scopes: an empty Array' do
            let(:scopes) { [] }

            it { expect(scope).to be_a conjunction_scope_class }

            it { expect(scope.scopes).to be == scopes }
          end

          describe 'with scopes: an Array of Scopes' do
            let(:scopes) { Array.new(3) { build_scope } }

            it { expect(scope).to be_a conjunction_scope_class }

            it { expect(scope.scopes).to be == scopes }
          end
        end

        shared_examples 'should build a criteria scope' do
          let(:scope) { build_criteria(criteria: criteria) }

          # :nocov:
          unless criteria_scope_class
            pending '(must specify :criteria_class option)'

            next
          end
          # :nocov:

          describe 'with criteria: an empty Array' do
            let(:criteria) { [] }

            it { expect(scope).to be_a criteria_scope_class }

            it { expect(scope.criteria).to be == criteria }
          end

          describe 'with criteria: an Array of criteria' do
            let(:criteria) do
              operators = Cuprum::Collections::Queries::Operators

              [
                [
                  'title',
                  operators::EQUAL,
                  'The Word For World Is Forest'
                ],
                [
                  'author',
                  operators::EQUAL,
                  'Ursula K. LeGuin'
                ]
              ]
            end

            it { expect(scope).to be_a criteria_scope_class }

            it { expect(scope.criteria).to be == criteria }
          end
        end

        shared_examples 'should build a disjunction scope' do
          # :nocov:
          let(:scope) { build_container(scopes: scopes) }

          unless disjunction_scope_class
            pending '(must specify :disjunction_class option)'

            next
          end
          # :nocov:

          describe 'with scopes: an empty Array' do
            let(:scopes) { [] }

            it { expect(scope).to be_a disjunction_scope_class }

            it { expect(scope.scopes).to be == scopes }
          end

          describe 'with scopes: an Array of Scopes' do
            let(:scopes) { Array.new(3) { build_scope } }

            it { expect(scope).to be_a disjunction_scope_class }

            it { expect(scope.scopes).to be == scopes }
          end
        end

        shared_examples 'should build a negation scope' do
          let(:scope) { build_container(scopes: scopes) }

          # :nocov:
          unless negation_scope_class
            pending '(must specify :negation_class option)'

            next
          end
          # :nocov:

          describe 'with scopes: an empty Array' do
            let(:scopes) { [] }

            it { expect(scope).to be_a negation_scope_class }

            it { expect(scope.scopes).to be == scopes }
          end

          describe 'with scopes: an Array of Scopes' do
            let(:scopes) { Array.new(3) { build_scope } }

            it { expect(scope).to be_a negation_scope_class }

            it { expect(scope.scopes).to be == scopes }
          end
        end

        shared_examples 'should validate the criteria' do
          describe 'with criteria: nil' do
            let(:error_message) { 'criteria must be an Array' }

            it 'should raise an exception' do
              expect { build_criteria(criteria: nil) }
                .to raise_error ArgumentError, error_message
            end
          end

          describe 'with criteria: an Object' do
            let(:error_message) { 'criteria must be an Array' }

            it 'should raise an exception' do
              expect { build_criteria(criteria: Object.new.freeze) }
                .to raise_error ArgumentError, error_message
            end
          end

          describe 'with criteria: an Array of non-Array items' do
            let(:error_message) { 'criterion must be an Array of size 3' }

            it 'should raise an exception' do
              expect { build_criteria(criteria: [nil]) }
                .to raise_error ArgumentError, error_message
            end
          end

          describe 'with criteria: an Array of invalid Arrays' do
            let(:error_message) { 'criterion must be an Array of size 3' }

            it 'should raise an exception' do
              expect { build_criteria(criteria: [[], [], []]) }
                .to raise_error ArgumentError, error_message
            end
          end
        end

        shared_examples 'should validate the scopes' do
          describe 'with scopes: nil' do
            let(:error_message) { 'scopes must be an Array' }

            it 'should raise an exception' do
              expect { build_container(scopes: nil) }
                .to raise_error ArgumentError, error_message
            end
          end

          describe 'with scopes: an Object' do
            let(:error_message) { 'scopes must be an Array' }

            it 'should raise an exception' do
              expect { build_container(scopes: Object.new.freeze) }
                .to raise_error ArgumentError, error_message
            end
          end

          describe 'with scopes: an invalid Array' do
            let(:error_message) { 'scope must be a Scope instance' }

            it 'should raise an exception' do
              expect { build_container(scopes: [nil]) }
                .to raise_error ArgumentError, error_message
            end
          end
        end

        describe '.instance' do
          it 'should define the class method' do
            expect(described_class).to respond_to(:instance).with(0).arguments
          end

          it { expect(described_class.instance).to be_a described_class }

          it { expect(described_class.instance).to be subject }
        end

        describe '#build' do
          it 'should define the method' do
            expect(subject)
              .to respond_to(:build)
              .with(0..1).arguments
              .and_a_block
          end

          describe 'with an invalid scope' do
            let(:original) { build_scope }
            let(:error_class) do
              Cuprum::Collections::Scopes::Building::UnknownScopeTypeError
            end
            let(:error_message) do
              "#{described_class.name} cannot transform scopes of " \
                "type #{original.type.inspect} (#{original.class.name})"
            end

            before(:example) do
              allow(original).to receive(:type).and_return(:invalid)
            end

            it 'should raise an exception' do
              expect { subject.build(original) }
                .to raise_error error_class, error_message
            end
          end

          next if abstract

          describe 'with a block' do
            def build_criteria(criteria:)
              value = criteria.to_h do |(attribute, _, expected)|
                [attribute, expected]
              end
              block = -> { value }

              subject.build(&block)
            end

            def parse_criteria(...)
              subject.build(...).criteria
            end

            include_examples 'should build a criteria scope'

            include_contract 'should parse criteria from a block'
          end

          describe 'with a hash' do
            def build_criteria(criteria:)
              value = criteria.to_h do |(attribute, _, expected)|
                [attribute, expected]
              end

              subject.build(value)
            end

            def parse_criteria(value)
              subject.build(value).criteria
            end

            include_examples 'should build a criteria scope'

            include_contract 'should parse criteria from a hash'
          end

          describe 'with a conjunction scope' do
            def build_container(scopes:)
              original =
                Cuprum::Collections::Scopes::ConjunctionScope
                  .new(scopes: scopes)

              subject.build(original)
            end

            include_examples 'should build a conjunction scope'
          end

          describe 'with a criteria scope' do
            def build_criteria(criteria:)
              original =
                Cuprum::Collections::Scopes::CriteriaScope
                  .new(criteria: criteria)

              subject.build(original)
            end

            include_examples 'should build a criteria scope'
          end

          describe 'with a disjunction scope' do
            def build_container(scopes:)
              original =
                Cuprum::Collections::Scopes::DisjunctionScope
                  .new(scopes: scopes)

              subject.build(original)
            end

            include_examples 'should build a disjunction scope'
          end

          describe 'with a negation scope' do
            def build_container(scopes:)
              original =
                Cuprum::Collections::Scopes::NegationScope
                  .new(scopes: scopes)

              subject.build(original)
            end

            include_examples 'should build a negation scope'
          end
        end

        describe '#build_conjunction_scope' do
          let(:scope) { subject.build_conjunction_scope(scopes: scopes) }

          def build_container(scopes:)
            subject.build_conjunction_scope(scopes: scopes)
          end

          it 'should define the method' do
            expect(subject)
              .to respond_to(:build_conjunction_scope)
              .with(0).arguments
              .and_keywords(:scopes)
          end

          include_examples 'should validate the scopes'

          next if abstract

          include_examples 'should build a conjunction scope'
        end

        describe '#build_criteria_scope' do
          def build_criteria(criteria:)
            subject.build_criteria_scope(criteria: criteria)
          end

          it 'should define the method' do
            expect(subject)
              .to respond_to(:build_criteria_scope)
              .with(0).arguments
              .and_keywords(:criteria)
          end

          include_examples 'should validate the criteria'

          next if abstract

          include_examples 'should build a criteria scope'
        end

        describe '#build_disjunction_scope' do
          let(:scope) { subject.build_disjunction_scope(scopes: scopes) }

          def build_container(scopes:)
            subject.build_disjunction_scope(scopes: scopes)
          end

          it 'should define the method' do
            expect(subject)
              .to respond_to(:build_disjunction_scope)
              .with(0).arguments
              .and_keywords(:scopes)
          end

          include_examples 'should validate the scopes'

          next if abstract

          include_examples 'should build a disjunction scope'
        end

        describe '#build_negation_scope' do
          let(:scope) { subject.build_negation_scope(scopes: scopes) }

          def build_container(scopes:)
            subject.build_negation_scope(scopes: scopes)
          end

          it 'should define the method' do
            expect(subject)
              .to respond_to(:build_negation_scope)
              .with(0).arguments
              .and_keywords(:scopes)
          end

          include_examples 'should validate the scopes'

          next if abstract

          include_examples 'should build a negation scope'
        end

        describe '#transform_scope' do
          let(:scope) { subject.transform_scope(scope: original) }

          it 'should define the method' do
            expect(subject)
              .to respond_to(:transform_scope)
              .with(0).arguments
              .and_keywords(:scope)
          end

          describe 'with scope: nil' do
            let(:error_message) { 'scope must be a Scope instance' }

            it 'should raise an exception' do
              expect { subject.transform_scope(scope: nil) }
                .to raise_error ArgumentError, error_message
            end
          end

          describe 'with scope: an Object' do
            let(:error_message) { 'scope must be a Scope instance' }

            it 'should raise an exception' do
              expect { subject.transform_scope(scope: Object.new.freeze) }
                .to raise_error ArgumentError, error_message
            end
          end

          describe 'with an invalid scope' do
            let(:original) { build_scope }
            let(:error_class) do
              Cuprum::Collections::Scopes::Building::UnknownScopeTypeError
            end
            let(:error_message) do
              "#{described_class.name} cannot transform scopes of " \
                "type #{original.type.inspect} (#{original.class.name})"
            end

            before(:example) do
              allow(original).to receive(:type).and_return(:invalid)
            end

            it 'should raise an exception' do
              expect { subject.transform_scope(scope: original) }
                .to raise_error error_class, error_message
            end
          end

          next if abstract

          describe 'with a conjunction scope' do
            def build_container(scopes:)
              original =
                Cuprum::Collections::Scopes::ConjunctionScope
                  .new(scopes: scopes)

              subject.transform_scope(scope: original)
            end

            include_examples 'should build a conjunction scope'
          end

          describe 'with a criteria scope' do
            def build_criteria(criteria:)
              original =
                Cuprum::Collections::Scopes::CriteriaScope
                  .new(criteria: criteria)

              subject.transform_scope(scope: original)
            end

            include_examples 'should build a criteria scope'
          end

          describe 'with a disjunction scope' do
            def build_container(scopes:)
              original =
                Cuprum::Collections::Scopes::DisjunctionScope
                  .new(scopes: scopes)

              subject.transform_scope(scope: original)
            end

            include_examples 'should build a disjunction scope'
          end

          describe 'with a negation scope' do
            def build_container(scopes:)
              original =
                Cuprum::Collections::Scopes::NegationScope
                  .new(scopes: scopes)

              subject.transform_scope(scope: original)
            end

            include_examples 'should build a negation scope'
          end
        end
      end
    end
  end
end
