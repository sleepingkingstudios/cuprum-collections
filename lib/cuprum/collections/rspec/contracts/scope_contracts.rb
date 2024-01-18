# frozen_string_literal: true

require 'cuprum/collections/rspec/contracts'
require 'cuprum/collections/rspec/fixtures'
require 'cuprum/collections/scope'

module Cuprum::Collections::RSpec::Contracts
  # Contracts for asserting on scope objects.
  module ScopeContracts
    # Contract validating the behavior of a Container scope implementation.
    module ShouldBeAContainerScopeContract
      extend RSpec::SleepingKingStudios::Contract

      # @!method apply(example_group)
      #   Adds the contract to the example group.
      #
      #   @param example_group [RSpec::Core::ExampleGroup] the example group to
      #     which the contract is applied.
      contract do
        shared_context 'with scopes' do
          let(:scopes) do
            [
              described_class.new(scopes: []),
              described_class.new(scopes: []),
              described_class.new(scopes: [])
            ]
          end
        end

        describe '.new' do
          it 'should define the constructor' do
            expect(described_class)
              .to be_constructible
              .with(0).arguments
              .and_keywords(:scopes)
              .and_any_keywords
          end
        end

        describe '#empty?' do
          include_examples 'should define predicate', :empty?, true

          wrap_context 'with scopes' do
            it { expect(subject.empty?).to be false }
          end
        end

        describe '#scopes' do
          include_examples 'should define reader', :scopes, -> { scopes }

          wrap_context 'with scopes' do
            it { expect(subject.scopes).to be == scopes }
          end
        end

        describe '#with_scopes' do
          let(:new_scopes) do
            [
              described_class.new(scopes: []),
              described_class.new(scopes: [])
            ]
          end

          it { expect(subject).to respond_to(:with_scopes).with(1).arguments }

          it 'should return a scope' do
            expect(subject.with_scopes(new_scopes)).to be_a described_class
          end

          it "should not change the original scope's child scopes" do
            expect { subject.with_scopes(new_scopes) }
              .not_to change(subject, :scopes)
          end

          it "should set the copied scope's child scopes" do
            expect(subject.with_scopes(new_scopes).scopes)
              .to be == new_scopes
          end

          wrap_context 'with scopes' do
            it "should not change the original scope's child scopes" do
              expect { subject.with_scopes(new_scopes) }
                .not_to change(subject, :scopes)
            end

            it "should set the copied scope's child scopes" do
              expect(subject.with_scopes(new_scopes).scopes)
                .to be == new_scopes
            end
          end
        end
      end
    end

    # Contract validating the behavior of a Null scope implementation.
    module ShouldBeANullScopeContract
      extend RSpec::SleepingKingStudios::Contract

      # @!method apply(example_group, abstract: false)
      #   Adds the contract to the example group.
      #
      #   @param example_group [RSpec::Core::ExampleGroup] the example group to
      #     which the contract is applied.
      #   @param abstract [Boolean] if true, the scope is abstract and does not
      #     define a #call implementation. Defaults to false.
      contract do |abstract: false|
        describe '#and' do
          shared_examples 'should return the scope' do
            it { expect(outer).to be_a Cuprum::Collections::Scopes::Base }

            it { expect(outer.type).to be :criteria }

            it { expect(outer.criteria).to be == expected }
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

          describe 'with a block' do
            let(:block) { -> { { 'title' => 'A Wizard of Earthsea' } } }
            let(:outer) { subject.and(&block) }

            include_examples 'should return the scope'
          end

          describe 'with a hash' do
            let(:value) { { 'title' => 'A Wizard of Earthsea' } }
            let(:outer) { subject.and(value) }

            include_examples 'should return the scope'
          end

          describe 'with a scope' do
            let(:value) do
              Cuprum::Collections::Scope
                .new({ 'title' => 'A Wizard of Earthsea' })
            end
            let(:outer) { subject.and(value) }

            include_examples 'should return the scope'
          end
        end

        describe '#call' do
          shared_context 'with data' do
            let(:data) do
              Cuprum::Collections::RSpec::Fixtures::BOOKS_FIXTURES
            end
          end

          next if abstract

          describe 'with empty data' do
            let(:data)     { [] }
            let(:expected) { data }

            it { expect(filtered_data).to be == expected }
          end

          wrap_context 'with data' do
            let(:expected) { data }

            it { expect(filtered_data).to be == expected }
          end
        end

        describe '#empty?' do
          include_examples 'should define predicate', :empty?, true
        end

        describe '#or' do
          shared_examples 'should return the scope' do
            it { expect(outer).to be_a Cuprum::Collections::Scopes::Base }

            it { expect(outer.type).to be :criteria }

            it { expect(outer.criteria).to be == expected }
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

          describe 'with a block' do
            let(:block) { -> { { 'title' => 'A Wizard of Earthsea' } } }
            let(:outer) { subject.or(&block) }

            include_examples 'should return the scope'
          end

          describe 'with a hash' do
            let(:value) { { 'title' => 'A Wizard of Earthsea' } }
            let(:outer) { subject.or(value) }

            include_examples 'should return the scope'
          end

          describe 'with a scope' do
            let(:value) do
              Cuprum::Collections::Scope
                .new({ 'title' => 'A Wizard of Earthsea' })
            end
            let(:outer) { subject.or(value) }

            include_examples 'should return the scope'
          end
        end

        describe '#not' do
          shared_examples 'should invert and return the scope' do
            it { expect(outer).to be_a Cuprum::Collections::Scopes::Base }

            it { expect(outer.type).to be :negation }

            it { expect(outer.scopes.size).to be 1 }

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

          describe 'with a block' do
            let(:block) { -> { { 'title' => 'A Wizard of Earthsea' } } }
            let(:outer) { subject.not(&block) }
            let(:inner) { outer.scopes.first }

            include_examples 'should invert and return the scope'
          end

          describe 'with a hash' do
            let(:value) { { 'title' => 'A Wizard of Earthsea' } }
            let(:outer) { subject.not(value) }
            let(:inner) { outer.scopes.first }

            include_examples 'should invert and return the scope'
          end

          describe 'with a scope' do
            let(:value) do
              Cuprum::Collections::Scope
                .new({ 'title' => 'A Wizard of Earthsea' })
            end
            let(:outer) { subject.not(value) }
            let(:inner) { outer.scopes.first }

            include_examples 'should invert and return the scope'
          end
        end

        describe '#type' do
          include_examples 'should define reader', :type, :null
        end
      end
    end
  end
end
