# frozen_string_literal: true

require 'rspec/sleeping_king_studios/deferred'

require 'cuprum/collections/rspec/deferred/scope_examples'
require 'cuprum/collections/rspec/deferred/scopes'

module Cuprum::Collections::RSpec::Deferred::Scopes
  # Deferred examples for asserting on None scope objects.
  module NoneExamples
    include RSpec::SleepingKingStudios::Deferred::Provider
    include Cuprum::Collections::RSpec::Deferred::ScopeExamples

    deferred_examples 'should implement the NoneScope methods' \
    do |**deferred_options|
      include_deferred 'should implement the Scope methods'

      include_deferred 'should compose Scopes as a NoneScope'

      unless deferred_options.fetch(:abstract, false)
        include_deferred 'should match no data'
      end

      describe '#==' do
        describe 'with a scope with the same class' do
          let(:other) { described_class.new }

          it { expect(subject == other).to be true }
        end

        describe 'with a scope with the same type' do
          let(:other) { Spec::CustomScope.new }

          example_class 'Spec::CustomScope',
            Cuprum::Collections::Scopes::Base \
          do |klass|
            klass.define_method(:type) { :none }
          end

          it { expect(subject == other).to be true }
        end
      end

      describe '#as_json' do
        let(:expected) { { 'type' => subject.type } }

        it { expect(subject.as_json).to be == expected }
      end

      describe '#empty?' do
        it { expect(subject.empty?).to be false }
      end

      describe '#invert' do
        let(:expected) { Cuprum::Collections::Scopes::AllScope.new }

        it { expect(subject.invert).to be == expected }
      end

      describe '#type' do
        it { expect(subject.type).to be :none }
      end
    end

    deferred_examples 'should compose Scopes as a NoneScope' do
      describe '#and' do
        it 'should define the method' do
          expect(subject)
            .to respond_to(:and)
            .with(0..1).arguments
            .and_a_block
        end

        it { expect(subject).to have_aliased_method(:and).as(:where) }

        describe 'with a block' do
          let(:block) { -> { { 'title' => 'A Wizard of Earthsea' } } }

          it { expect(subject.and(&block)).to be subject }
        end

        describe 'with a hash' do
          let(:value) { { 'title' => 'A Wizard of Earthsea' } }

          it { expect(subject.and(value)).to be subject }
        end

        describe 'with an all scope' do
          let(:original) do
            Cuprum::Collections::Scopes::AllScope.new
          end

          it { expect(subject.and(original)).to be subject }
        end

        describe 'with a none scope' do
          let(:original) do
            Cuprum::Collections::Scopes::NoneScope.new
          end

          it { expect(subject.and(original)).to be subject }
        end

        describe 'with an empty conjunction scope' do
          let(:original) do
            Cuprum::Collections::Scopes::ConjunctionScope.new(scopes: [])
          end

          it { expect(subject.and(original)).to be subject }
        end

        describe 'with an empty criteria scope' do
          let(:original) do
            Cuprum::Collections::Scopes::CriteriaScope.new(criteria: [])
          end

          it { expect(subject.and(original)).to be subject }
        end

        describe 'with an empty disjunction scope' do
          let(:original) do
            Cuprum::Collections::Scopes::DisjunctionScope.new(scopes: [])
          end

          it { expect(subject.and(original)).to be subject }
        end

        describe 'with a non-empty conjunction scope' do
          let(:original) do
            wrapped =
              Cuprum::Collections::Scope
                .new({ 'title' => 'A Wizard of Earthsea' })

            Cuprum::Collections::Scopes::ConjunctionScope
              .new(scopes: [wrapped])
          end

          it { expect(subject.and(original)).to be subject }
        end

        describe 'with a non-empty criteria scope' do
          let(:original) do
            Cuprum::Collections::Scope
              .new({ 'title' => 'A Wizard of Earthsea' })
          end

          it { expect(subject.and(original)).to be subject }
        end

        describe 'with a non-empty disjunction scope' do
          let(:original) do
            wrapped =
              Cuprum::Collections::Scope
                .new({ 'title' => 'A Wizard of Earthsea' })

            Cuprum::Collections::Scopes::DisjunctionScope
              .new(scopes: [wrapped])
          end

          it { expect(subject.and(original)).to be subject }
        end
      end

      describe '#not' do
        it 'should define the method' do
          expect(subject)
            .to respond_to(:not)
            .with(0..1).arguments
            .and_a_block
        end

        describe 'with a block' do
          let(:block) { -> { { 'title' => 'A Wizard of Earthsea' } } }

          it { expect(subject.not(&block)).to be subject }
        end

        describe 'with a hash' do
          let(:value) { { 'title' => 'A Wizard of Earthsea' } }

          it { expect(subject.not(value)).to be subject }
        end

        describe 'with an all scope' do
          let(:original) do
            Cuprum::Collections::Scopes::AllScope.new
          end

          it { expect(subject.not(original)).to be subject }
        end

        describe 'with a none scope' do
          let(:original) do
            Cuprum::Collections::Scopes::AllScope.new
          end

          it { expect(subject.not(original)).to be subject }
        end

        describe 'with an empty conjunction scope' do
          let(:original) do
            Cuprum::Collections::Scopes::ConjunctionScope.new(scopes: [])
          end

          it { expect(subject.not(original)).to be subject }
        end

        describe 'with an empty criteria scope' do
          let(:original) do
            Cuprum::Collections::Scopes::CriteriaScope.new(criteria: [])
          end

          it { expect(subject.not(original)).to be subject }
        end

        describe 'with an empty disjunction scope' do
          let(:original) do
            Cuprum::Collections::Scopes::DisjunctionScope.new(scopes: [])
          end

          it { expect(subject.not(original)).to be subject }
        end

        describe 'with a non-empty conjunction scope' do
          let(:original) do
            wrapped =
              Cuprum::Collections::Scope
                .new({ 'title' => 'A Wizard of Earthsea' })

            Cuprum::Collections::Scopes::ConjunctionScope
              .new(scopes: [wrapped])
          end

          it { expect(subject.not(original)).to be subject }
        end

        describe 'with a non-empty criteria scope' do
          let(:original) do
            Cuprum::Collections::Scope
              .new({ 'title' => 'A Wizard of Earthsea' })
          end

          it { expect(subject.not(original)).to be subject }
        end

        describe 'with a non-empty disjunction scope' do
          let(:original) do
            wrapped =
              Cuprum::Collections::Scope
                .new({ 'title' => 'A Wizard of Earthsea' })

            Cuprum::Collections::Scopes::DisjunctionScope
              .new(scopes: [wrapped])
          end

          it { expect(subject.not(original)).to be subject }
        end
      end

      describe '#or' do
        it 'should define the method' do
          expect(subject)
            .to respond_to(:or)
            .with(0..1).arguments
            .and_a_block
        end

        describe 'with a block' do
          let(:block) { -> { { 'title' => 'A Wizard of Earthsea' } } }
          let(:expected) do
            Cuprum::Collections::Scope.new(&block)
          end

          it { expect(subject.or(&block)).to be == expected }
        end

        describe 'with a hash' do
          let(:value) { { 'title' => 'A Wizard of Earthsea' } }
          let(:expected) do
            Cuprum::Collections::Scope.new(value)
          end

          it { expect(subject.or(value)).to be == expected }
        end

        describe 'with an all scope' do
          let(:original) do
            Cuprum::Collections::Scopes::AllScope.new
          end

          it { expect(subject.or(original)).to be == original }
        end

        describe 'with a none scope' do
          let(:original) do
            Cuprum::Collections::Scopes::NoneScope.new
          end

          it { expect(subject.or(original)).to be == original }
        end

        describe 'with an empty conjunction scope' do
          let(:original) do
            Cuprum::Collections::Scopes::ConjunctionScope.new(scopes: [])
          end

          it { expect(subject.or(original)).to be subject }
        end

        describe 'with an empty criteria scope' do
          let(:original) do
            Cuprum::Collections::Scopes::CriteriaScope.new(criteria: [])
          end

          it { expect(subject.or(original)).to be subject }
        end

        describe 'with an empty disjunction scope' do
          let(:original) do
            Cuprum::Collections::Scopes::DisjunctionScope.new(scopes: [])
          end

          it { expect(subject.or(original)).to be subject }
        end

        describe 'with a non-empty conjunction scope' do
          let(:original) do
            wrapped =
              Cuprum::Collections::Scope
                .new({ 'title' => 'A Wizard of Earthsea' })

            Cuprum::Collections::Scopes::ConjunctionScope
              .new(scopes: [wrapped])
          end

          it { expect(subject.or(original)).to be == original }
        end

        describe 'with a non-empty criteria scope' do
          let(:original) do
            Cuprum::Collections::Scope
              .new({ 'title' => 'A Wizard of Earthsea' })
          end

          it { expect(subject.or(original)).to be == original }
        end

        describe 'with a non-empty disjunction scope' do
          let(:original) do
            wrapped =
              Cuprum::Collections::Scope
                .new({ 'title' => 'A Wizard of Earthsea' })

            Cuprum::Collections::Scopes::DisjunctionScope
              .new(scopes: [wrapped])
          end

          it { expect(subject.or(original)).to be == original }
        end
      end
    end

    deferred_examples 'should match no data' do
      describe '#call' do
        shared_context 'with data' do
          let(:data) do
            Cuprum::Collections::RSpec::Fixtures::BOOKS_FIXTURES
          end
        end

        describe 'with empty data' do
          let(:data) { [] }

          it { expect(filtered_data).to be == [] }
        end

        wrap_context 'with data' do
          let(:expected) { [] }

          it { expect(filtered_data).to match_array expected }
        end
      end
    end
  end
end
