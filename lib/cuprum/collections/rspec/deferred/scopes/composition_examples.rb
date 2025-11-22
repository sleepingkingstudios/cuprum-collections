# frozen_string_literal: true

require 'rspec/sleeping_king_studios/deferred'

require 'cuprum/collections/rspec/deferred/scopes'

module Cuprum::Collections::RSpec::Deferred::Scopes
  # Deferred examples for asserting on scope composition.
  module CompositionExamples
    include RSpec::SleepingKingStudios::Deferred::Provider

    deferred_context 'with contexts for composable scopes' do
      deferred_context 'with an all scope' do
        let(:original) do
          Cuprum::Collections::Scopes::AllScope.new
        end
      end

      deferred_context 'with a none scope' do
        let(:original) do
          Cuprum::Collections::Scopes::NoneScope.new
        end
      end

      deferred_context 'with an empty conjunction scope' do
        let(:original) do
          Cuprum::Collections::Scopes::ConjunctionScope.new(scopes: [])
        end
      end

      deferred_context 'with an empty criteria scope' do
        let(:original) do
          Cuprum::Collections::Scopes::CriteriaScope.new(criteria: [])
        end
      end

      deferred_context 'with an empty disjunction scope' do
        let(:original) do
          Cuprum::Collections::Scopes::DisjunctionScope.new(scopes: [])
        end
      end

      deferred_context 'with a non-empty conjunction scope' do
        let(:original) do
          operators = Cuprum::Collections::Queries::Operators
          criteria  = [
            [
              'category',
              operators::EQUAL,
              'Science Fiction and Fantasy'
            ]
          ]
          wrapped =
            Cuprum::Collections::Scopes::CriteriaScope.new(criteria:)

          Cuprum::Collections::Scopes::ConjunctionScope.new(scopes: [wrapped])
        end
      end

      deferred_context 'with a non-empty criteria scope' do
        let(:original) do
          operators = Cuprum::Collections::Queries::Operators
          criteria  = [
            [
              'category',
              operators::EQUAL,
              'Science Fiction and Fantasy'
            ]
          ]

          Cuprum::Collections::Scopes::CriteriaScope.new(criteria:)
        end
      end

      deferred_context 'with a non-empty disjunction scope' do
        let(:original) do
          operators = Cuprum::Collections::Queries::Operators
          criteria  = [
            [
              'category',
              operators::EQUAL,
              'Science Fiction and Fantasy'
            ]
          ]
          wrapped =
            Cuprum::Collections::Scopes::CriteriaScope.new(criteria:)

          Cuprum::Collections::Scopes::DisjunctionScope.new(scopes: [wrapped])
        end
      end
    end
  end
end
