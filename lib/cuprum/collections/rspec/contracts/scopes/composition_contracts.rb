# frozen_string_literal: true

require 'cuprum/collections/queries'
require 'cuprum/collections/rspec/contracts/scopes'
require 'cuprum/collections/scopes/base'
require 'cuprum/collections/scopes/builder'
require 'cuprum/collections/scopes/conjunction_scope'
require 'cuprum/collections/scopes/criteria_scope'
require 'cuprum/collections/scopes/disjunction_scope'
require 'cuprum/collections/scopes/negation_scope'

module Cuprum::Collections::RSpec::Contracts::Scopes
  # Contracts for validating the behavior of scope composition.
  module CompositionContracts
    # Contract validating the fluent interface for scope composition.
    module ShouldComposeScopesContract
      extend RSpec::SleepingKingStudios::Contract

      # @!method apply(example_group, except: [])
      #   Adds the contract to the example group.
      #
      #   @param example_group [RSpec::Core::ExampleGroup] the example group to
      #     which the contract is applied.
      #   @param except [Array<Symbol>] names of composition methods where the
      #     scope defines custom behavior.
      contract do |except: []|
        describe '#and' do
          shared_examples 'should combine the scopes with logical AND' do
            it { expect(outer).to be_a Cuprum::Collections::Scopes::Base }

            it { expect(outer.type).to be :conjunction }

            it { expect(outer.scopes.size).to be 2 }

            it { expect(outer.scopes.first).to be subject }

            it { expect(inner).to be_a Cuprum::Collections::Scopes::Base }

            it { expect(inner.type).to be :criteria }

            it { expect(inner.criteria).to be == expected }
          end

          let(:expected) do
            operators = Cuprum::Collections::Queries::Operators

            [
              [
                'title',
                operators::EQUAL,
                'A Wizard of Earthsea'
              ]
            ]
          end

          it 'should define the method' do
            expect(subject)
              .to respond_to(:and)
              .with(0..1).arguments
              .and_a_block
          end

          it { expect(subject).to have_aliased_method(:and).as(:where) }

          next if except.include?(:and)

          describe 'with a block' do
            let(:block) { -> { { 'title' => 'A Wizard of Earthsea' } } }
            let(:outer) { subject.and(&block) }
            let(:inner) { outer.scopes.last }

            include_examples 'should combine the scopes with logical AND'
          end

          describe 'with a hash' do
            let(:value) { { 'title' => 'A Wizard of Earthsea' } }
            let(:outer) { subject.and(value) }
            let(:inner) { outer.scopes.last }

            include_examples 'should combine the scopes with logical AND'
          end

          describe 'with a scope' do
            let(:original) do
              Cuprum::Collections::Scopes::CriteriaScope.new(criteria: expected)
            end
            let(:outer) { subject.and(original) }
            let(:inner) { outer.scopes.last }

            include_examples 'should combine the scopes with logical AND'
          end
        end

        describe '#not' do
          shared_examples 'should combine the scopes with logical NAND' do
            it { expect(outer).to be_a Cuprum::Collections::Scopes::Base }

            it { expect(outer.type).to be :conjunction }

            it { expect(outer.scopes.size).to be 2 }

            it { expect(outer.scopes.first).to be subject }

            it { expect(invert).to be_a Cuprum::Collections::Scopes::Base }

            it { expect(invert.type).to be :negation }

            it { expect(invert.scopes.size).to be 1 }

            it { expect(inner).to be_a Cuprum::Collections::Scopes::Base }

            it { expect(inner.type).to be :criteria }

            it { expect(inner.criteria).to be == expected }
          end

          let(:expected) do
            operators = Cuprum::Collections::Queries::Operators

            [
              [
                'title',
                operators::EQUAL,
                'A Wizard of Earthsea'
              ]
            ]
          end

          it 'should define the method' do
            expect(subject)
              .to respond_to(:not)
              .with(0..1).arguments
              .and_a_block
          end

          next if except.include?(:not)

          describe 'with a block' do
            let(:block)  { -> { { 'title' => 'A Wizard of Earthsea' } } }
            let(:outer)  { subject.not(&block) }
            let(:invert) { outer.scopes.last }
            let(:inner)  { invert.scopes.first }

            include_examples 'should combine the scopes with logical NAND'
          end

          describe 'with a hash' do
            let(:value)  { { 'title' => 'A Wizard of Earthsea' } }
            let(:outer)  { subject.not(value) }
            let(:invert) { outer.scopes.last }
            let(:inner)  { invert.scopes.first }

            include_examples 'should combine the scopes with logical NAND'
          end

          describe 'with a scope' do
            let(:original) do
              Cuprum::Collections::Scopes::CriteriaScope.new(criteria: expected)
            end
            let(:outer)  { subject.not(original) }
            let(:invert) { outer.scopes.last }
            let(:inner)  { invert.scopes.last }

            include_examples 'should combine the scopes with logical NAND'
          end
        end

        describe '#or' do
          shared_examples 'should combine the scopes with logical OR' do
            it { expect(outer).to be_a Cuprum::Collections::Scopes::Base }

            it { expect(outer.type).to be :disjunction }

            it { expect(outer.scopes.size).to be 2 }

            it { expect(outer.scopes.first).to be subject }

            it { expect(inner).to be_a Cuprum::Collections::Scopes::Base }

            it { expect(inner.type).to be :criteria }

            it { expect(inner.criteria).to be == expected }
          end

          let(:expected) do
            operators = Cuprum::Collections::Queries::Operators

            [
              [
                'title',
                operators::EQUAL,
                'A Wizard of Earthsea'
              ]
            ]
          end

          it 'should define the method' do
            expect(subject)
              .to respond_to(:or)
              .with(0..1).arguments
              .and_a_block
          end

          next if except.include?(:or)

          describe 'with a block' do
            let(:block) { -> { { 'title' => 'A Wizard of Earthsea' } } }
            let(:outer) { subject.or(&block) }
            let(:inner) { outer.scopes.last }

            include_examples 'should combine the scopes with logical OR'
          end

          describe 'with a hash' do
            let(:value) { { 'title' => 'A Wizard of Earthsea' } }
            let(:outer) { subject.or(value) }
            let(:inner) { outer.scopes.last }

            include_examples 'should combine the scopes with logical OR'
          end

          describe 'with a scope' do
            let(:original) do
              Cuprum::Collections::Scopes::CriteriaScope.new(criteria: expected)
            end
            let(:outer) { subject.or(original) }
            let(:inner) { outer.scopes.last }

            include_examples 'should combine the scopes with logical OR'
          end
        end
      end
    end

    # Contract validating scope composition for conjunction scopes.
    module ShouldComposeScopesForConjunctionContract
      extend  RSpec::SleepingKingStudios::Contract
      include Cuprum::Collections::RSpec::Contracts::Scopes::CompositionContracts # rubocop:disable Layout/LineLength

      # @!method apply(example_group)
      #   Adds the contract to the example group.
      #
      #   @param example_group [RSpec::Core::ExampleGroup] the example group to
      #     which the contract is applied.
      contract do
        shared_context 'when the scope has many child scopes' do
          let(:scopes) do
            [
              build_scope({ 'author' => 'J.R.R. Tolkien' }),
              build_scope({ 'series' => 'The Lord of the Rings' }),
              build_scope do
                { 'published_at' => less_than('1955-01-01') }
              end
            ]
          end
        end

        include_contract 'should compose scopes', except: %i[and not]

        describe '#and' do
          shared_examples 'should combine the scopes with logical AND' do
            it { expect(outer).to be_a Cuprum::Collections::Scopes::Base }

            it { expect(outer.type).to be :conjunction }

            it { expect(outer.scopes.size).to be scopes.size + 1 }

            it { expect(inner).to be_a Cuprum::Collections::Scopes::Base }

            it { expect(inner.type).to be :criteria }

            it { expect(inner.criteria).to be == expected }
          end

          let(:expected) do
            operators = Cuprum::Collections::Queries::Operators

            [
              [
                'title',
                operators::EQUAL,
                'A Wizard of Earthsea'
              ]
            ]
          end

          describe 'with a block' do
            let(:block) { -> { { 'title' => 'A Wizard of Earthsea' } } }
            let(:outer) { subject.and(&block) }
            let(:inner) { outer.scopes.last }

            include_examples 'should combine the scopes with logical AND'

            wrap_context 'when the scope has many child scopes' do
              include_examples 'should combine the scopes with logical AND'

              it { expect(outer.scopes[0...scopes.size]).to be == scopes }
            end
          end

          describe 'with a hash' do
            let(:value) { { 'title' => 'A Wizard of Earthsea' } }
            let(:outer) { subject.and(value) }
            let(:inner) { outer.scopes.last }

            include_examples 'should combine the scopes with logical AND'

            wrap_context 'when the scope has many child scopes' do
              include_examples 'should combine the scopes with logical AND'

              it { expect(outer.scopes[0...scopes.size]).to be == scopes }
            end
          end

          describe 'with a conjunction scope' do
            let(:original) do
              wrapped =
                Cuprum::Collections::Scopes::CriteriaScope
                  .new(criteria: expected)

              Cuprum::Collections::Scopes::ConjunctionScope
                .new(scopes: [wrapped])
            end
            let(:outer) { subject.and(original) }
            let(:inner) { outer.scopes.last }

            it { expect(outer).to be_a Cuprum::Collections::Scopes::Base }

            it { expect(outer.type).to be :conjunction }

            it { expect(outer.scopes.size).to be scopes.size + 1 }

            it { expect(inner).to be_a Cuprum::Collections::Scopes::Base }

            it { expect(inner.type).to be :criteria }

            it { expect(inner.criteria).to be == expected }

            wrap_context 'when the scope has many child scopes' do
              it { expect(outer.scopes.size).to be scopes.size + 1 }

              it { expect(inner).to be_a Cuprum::Collections::Scopes::Base }

              it { expect(inner.type).to be :criteria }

              it { expect(inner.criteria).to be == expected }
            end
          end

          describe 'with a non-conjunction scope' do
            let(:original) do
              Cuprum::Collections::Scopes::CriteriaScope.new(criteria: expected)
            end
            let(:outer) { subject.and(original) }
            let(:inner) { outer.scopes.last }

            include_examples 'should combine the scopes with logical AND'

            wrap_context 'when the scope has many child scopes' do
              include_examples 'should combine the scopes with logical AND'

              it { expect(outer.scopes[0...scopes.size]).to be == scopes }
            end
          end
        end

        describe '#not' do
          shared_examples 'should combine the scopes with logical NAND' do
            it { expect(outer).to be_a Cuprum::Collections::Scopes::Base }

            it { expect(outer.type).to be :conjunction }

            it { expect(outer.scopes.size).to be scopes.size + 1 }

            it { expect(invert).to be_a Cuprum::Collections::Scopes::Base }

            it { expect(invert.type).to be :negation }

            it { expect(invert.scopes.size).to be 1 }

            it { expect(inner).to be_a Cuprum::Collections::Scopes::Base }

            it { expect(inner.type).to be :criteria }

            it { expect(inner.criteria).to be == expected }
          end

          let(:expected) do
            operators = Cuprum::Collections::Queries::Operators

            [
              [
                'title',
                operators::EQUAL,
                'A Wizard of Earthsea'
              ]
            ]
          end

          describe 'with a block' do
            let(:block)  { -> { { 'title' => 'A Wizard of Earthsea' } } }
            let(:outer)  { subject.not(&block) }
            let(:invert) { outer.scopes.last }
            let(:inner)  { invert.scopes.first }

            include_examples 'should combine the scopes with logical NAND'

            wrap_context 'when the scope has many child scopes' do
              include_examples 'should combine the scopes with logical NAND'

              it { expect(outer.scopes[0...scopes.size]).to be == scopes }
            end
          end

          describe 'with a hash' do
            let(:value)  { { 'title' => 'A Wizard of Earthsea' } }
            let(:outer)  { subject.not(value) }
            let(:invert) { outer.scopes.last }
            let(:inner)  { invert.scopes.first }

            include_examples 'should combine the scopes with logical NAND'

            wrap_context 'when the scope has many child scopes' do
              include_examples 'should combine the scopes with logical NAND'

              it { expect(outer.scopes[0...scopes.size]).to be == scopes }
            end
          end

          describe 'with a scope' do
            let(:original) do
              Cuprum::Collections::Scopes::CriteriaScope.new(criteria: expected)
            end
            let(:outer)  { subject.not(original) }
            let(:invert) { outer.scopes.last }
            let(:inner)  { invert.scopes.last }

            include_examples 'should combine the scopes with logical NAND'

            wrap_context 'when the scope has many child scopes' do
              include_examples 'should combine the scopes with logical NAND'

              it { expect(outer.scopes[0...scopes.size]).to be == scopes }
            end
          end
        end
      end
    end

    # Contract validating scope composition for conjunction scopes.
    module ShouldComposeScopesForCriteriaContract
      extend  RSpec::SleepingKingStudios::Contract
      include Cuprum::Collections::RSpec::Contracts::Scopes::CompositionContracts # rubocop:disable Layout/LineLength

      # @!method apply(example_group)
      #   Adds the contract to the example group.
      #
      #   @param example_group [RSpec::Core::ExampleGroup] the example group to
      #     which the contract is applied.
      contract do
        shared_context 'when the scope has multiple criteria' do
          let(:criteria) do
            operators = Cuprum::Collections::Queries::Operators

            [
              [
                'author',
                operators::EQUAL,
                'Ursula K. LeGuin'
              ],
              [
                'published_at',
                operators::LESS_THAN,
                '1970-01-01'
              ]
            ]
          end
        end

        include_contract 'should compose scopes', except: %i[and]

        describe '#and' do
          shared_examples 'should merge the criteria' do
            it { expect(outer).to be_a Cuprum::Collections::Scopes::Base }

            it { expect(outer.type).to be :criteria }

            it { expect(outer.criteria).to be == [*criteria, *expected] }
          end

          let(:expected) do
            operators = Cuprum::Collections::Queries::Operators

            [
              [
                'title',
                operators::EQUAL,
                'A Wizard of Earthsea'
              ]
            ]
          end

          describe 'with a block' do
            let(:block) { -> { { 'title' => 'A Wizard of Earthsea' } } }
            let(:outer) { subject.and(&block) }

            include_examples 'should merge the criteria'

            wrap_context 'when the scope has multiple criteria' do
              include_examples 'should merge the criteria'
            end
          end

          describe 'with a hash' do
            let(:value) { { 'title' => 'A Wizard of Earthsea' } }
            let(:outer) { subject.and(value) }

            include_examples 'should merge the criteria'

            wrap_context 'when the scope has multiple criteria' do
              include_examples 'should merge the criteria'
            end
          end

          describe 'with a criteria scope' do
            let(:other_scope) do
              Cuprum::Collections::Scopes::CriteriaScope
                .new(criteria: expected)
            end
            let(:outer) { subject.and(other_scope) }

            include_examples 'should merge the criteria'

            wrap_context 'when the scope has multiple criteria' do
              include_examples 'should merge the criteria'
            end
          end

          describe 'with a non-criteria scope' do
            let(:other_scope) do
              wrapped =
                Cuprum::Collections::Scopes::CriteriaScope
                  .new(criteria: expected)

              Cuprum::Collections::Scopes::NegationScope.new(scopes: [wrapped])
            end
            let(:outer)  { subject.and(other_scope) }
            let(:invert) { outer.scopes.last }
            let(:inner)  { invert.scopes.last }

            it { expect(outer).to be_a Cuprum::Collections::Scopes::Base }

            it { expect(outer.type).to be :conjunction }

            it { expect(outer.scopes.size).to be 2 }

            it { expect(outer.scopes.first).to be subject }

            it { expect(invert).to be_a Cuprum::Collections::Scopes::Base }

            it { expect(invert.type).to be :negation }

            it { expect(invert.scopes.size).to be 1 }

            it { expect(inner).to be_a Cuprum::Collections::Scopes::Base }

            it { expect(inner.type).to be :criteria }

            it { expect(inner.criteria).to be == expected }
          end
        end
      end
    end

    # Contract validating scope composition for disjunction scopes.
    module ShouldComposeScopesForDisjunctionContract
      extend  RSpec::SleepingKingStudios::Contract
      include Cuprum::Collections::RSpec::Contracts::Scopes::CompositionContracts # rubocop:disable Layout/LineLength

      # @!method apply(example_group)
      #   Adds the contract to the example group.
      #
      #   @param example_group [RSpec::Core::ExampleGroup] the example group to
      #     which the contract is applied.
      contract do
        shared_context 'when the scope has many child scopes' do
          let(:scopes) do
            [
              build_scope({ 'author' => 'J.R.R. Tolkien' }),
              build_scope({ 'series' => 'The Lord of the Rings' }),
              build_scope do
                { 'published_at' => less_than('1955-01-01') }
              end
            ]
          end
        end

        include_contract 'should compose scopes', except: %i[or]

        describe '#or' do
          shared_examples 'should combine the scopes with logical OR' do
            it { expect(outer).to be_a Cuprum::Collections::Scopes::Base }

            it { expect(outer.type).to be :disjunction }

            it { expect(outer.scopes.size).to be scopes.size + 1 }

            it { expect(inner).to be_a Cuprum::Collections::Scopes::Base }

            it { expect(inner.type).to be :criteria }

            it { expect(inner.criteria).to be == expected }
          end

          let(:expected) do
            operators = Cuprum::Collections::Queries::Operators

            [
              [
                'title',
                operators::EQUAL,
                'A Wizard of Earthsea'
              ]
            ]
          end

          describe 'with a block' do
            let(:block) { -> { { 'title' => 'A Wizard of Earthsea' } } }
            let(:outer) { subject.or(&block) }
            let(:inner) { outer.scopes.last }

            include_examples 'should combine the scopes with logical OR'

            wrap_context 'when the scope has many child scopes' do
              include_examples 'should combine the scopes with logical OR'

              it { expect(outer.scopes[0...scopes.size]).to be == scopes }
            end
          end

          describe 'with a hash' do
            let(:value) { { 'title' => 'A Wizard of Earthsea' } }
            let(:outer) { subject.or(value) }
            let(:inner) { outer.scopes.last }

            include_examples 'should combine the scopes with logical OR'

            wrap_context 'when the scope has many child scopes' do
              include_examples 'should combine the scopes with logical OR'

              it { expect(outer.scopes[0...scopes.size]).to be == scopes }
            end
          end

          describe 'with a disjunction scope' do
            let(:original) do
              wrapped =
                Cuprum::Collections::Scopes::CriteriaScope
                  .new(criteria: expected)

              Cuprum::Collections::Scopes::DisjunctionScope
                .new(scopes: [wrapped])
            end
            let(:outer) { subject.or(original) }
            let(:inner) { outer.scopes.last }

            it { expect(outer).to be_a Cuprum::Collections::Scopes::Base }

            it { expect(outer.type).to be :disjunction }

            it { expect(outer.scopes.size).to be scopes.size + 1 }

            it { expect(inner).to be_a Cuprum::Collections::Scopes::Base }

            it { expect(inner.type).to be :criteria }

            it { expect(inner.criteria).to be == expected }

            wrap_context 'when the scope has many child scopes' do
              it { expect(outer.scopes.size).to be scopes.size + 1 }

              it { expect(inner).to be_a Cuprum::Collections::Scopes::Base }

              it { expect(inner.type).to be :criteria }

              it { expect(inner.criteria).to be == expected }
            end
          end

          describe 'with a non-disjunction scope' do
            let(:original) do
              Cuprum::Collections::Scopes::CriteriaScope.new(criteria: expected)
            end
            let(:outer) { subject.or(original) }
            let(:inner) { outer.scopes.last }

            include_examples 'should combine the scopes with logical OR'

            wrap_context 'when the scope has many child scopes' do
              include_examples 'should combine the scopes with logical OR'

              it { expect(outer.scopes[0...scopes.size]).to be == scopes }
            end
          end
        end
      end
    end
  end
end
