# frozen_string_literal: true

require 'cuprum/collections/queries'
require 'cuprum/collections/rspec/contracts/scopes'
require 'cuprum/collections/scopes/base'
require 'cuprum/collections/scopes/builder'

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

            it { expect(inner.criteria).to be == criteria }
          end

          let(:criteria) do
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
            let(:inner) do
              Cuprum::Collections::Scopes::CriteriaScope.new(criteria: criteria)
            end
            let(:outer) { subject.and(inner) }

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

            it { expect(inner.criteria).to be == criteria }
          end

          let(:criteria) do
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
            let(:inner) do
              Cuprum::Collections::Scopes::CriteriaScope.new(criteria: criteria)
            end
            let(:outer)  { subject.not(inner) }
            let(:invert) { outer.scopes.last }

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

            it { expect(inner.criteria).to be == criteria }
          end

          let(:criteria) do
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
            let(:inner) do
              Cuprum::Collections::Scopes::CriteriaScope.new(criteria: criteria)
            end
            let(:outer) { subject.or(inner) }

            include_examples 'should combine the scopes with logical OR'
          end
        end
      end
    end
  end
end
