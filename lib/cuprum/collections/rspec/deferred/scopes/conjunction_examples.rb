# frozen_string_literal: true

require 'rspec/sleeping_king_studios/deferred'

require 'cuprum/collections/rspec/deferred/scope_examples'
require 'cuprum/collections/rspec/deferred/scopes'
require 'cuprum/collections/rspec/deferred/scopes/composition_examples'

module Cuprum::Collections::RSpec::Deferred::Scopes
  # Deferred examples for asserting on Conjunction scope objects.
  module ConjunctionExamples
    include RSpec::SleepingKingStudios::Deferred::Provider
    include Cuprum::Collections::RSpec::Deferred::ScopeExamples
    include Cuprum::Collections::RSpec::Deferred::Scopes::CompositionExamples

    deferred_examples 'should implement the ConjunctionScope methods' \
    do |**deferred_options|
      deferred_context 'when the scope has many child scopes' do
        let(:scopes) do
          [
            build_scope({ 'author' => 'J.R.R. Tolkien' }),
            build_scope({ 'series' => 'The Lord of the Rings' }),
            build_scope do |scope|
              { 'published_at' => scope.less_than('1955-01-01') }
            end
          ]
        end
      end

      include_deferred 'should implement the Scope methods'

      include_deferred 'should define child scopes'

      include_deferred 'should compose Scopes as a ConjunctionScope'

      describe '#as_json' do
        let(:expected) do
          {
            'scopes' => subject.scopes.map(&:as_json),
            'type'   => subject.type
          }
        end

        it { expect(subject.as_json).to be == expected }

        wrap_deferred 'with scopes' do
          it { expect(subject.as_json).to be == expected }
        end
      end

      describe '#call' do
        next if deferred_options.fetch(:abstract, false)

        include_deferred 'should filter data by logical AND'
      end

      describe '#invert' do
        let(:expected) do
          Cuprum::Collections::Scopes::DisjunctionScope.new(
            scopes: subject.scopes.map(&:invert)
          )
        end

        it { expect(subject.invert).to be == expected }

        wrap_deferred 'with scopes' do
          it { expect(subject.invert).to be == expected }
        end
      end

      describe '#type' do
        include_examples 'should define reader', :type, :conjunction
      end
    end

    deferred_examples 'should compose Scopes as a ConjunctionScope' do
      describe '#and' do
        include_deferred 'with contexts for composable scopes'

        describe 'with a block' do
          let(:block) { -> { { 'title' => 'A Wizard of Earthsea' } } }
          let(:expected) do
            wrapped = Cuprum::Collections::Scope.new(&block)

            Cuprum::Collections::Scopes::ConjunctionScope.new(
              scopes: [*subject.scopes, wrapped]
            )
          end

          it { expect(subject.and(&block)).to be == expected }
        end

        describe 'with a hash' do
          let(:value) { { 'title' => 'A Wizard of Earthsea' } }
          let(:expected) do
            wrapped = Cuprum::Collections::Scope.new(value)

            Cuprum::Collections::Scopes::ConjunctionScope.new(
              scopes: [*subject.scopes, wrapped]
            )
          end

          it { expect(subject.and(value)).to be == expected }
        end

        wrap_deferred 'with an all scope' do
          it { expect(subject.and(original)).to be subject }
        end

        wrap_deferred 'with a none scope' do
          it { expect(subject.and(original)).to be == original }
        end

        wrap_deferred 'with an empty conjunction scope' do
          it { expect(subject.and(original)).to be subject }

          wrap_deferred 'when the scope has many child scopes' do
            it { expect(subject.and(original)).to be subject }
          end
        end

        wrap_deferred 'with an empty criteria scope' do
          it { expect(subject.and(original)).to be subject }
        end

        wrap_deferred 'with an empty disjunction scope' do
          it { expect(subject.and(original)).to be subject }
        end

        wrap_deferred 'with a non-empty conjunction scope' do
          let(:expected) do
            Cuprum::Collections::Scopes::ConjunctionScope.new(
              scopes: [*subject.scopes, *original.scopes]
            )
          end

          it { expect(subject.and(original)).to be == expected }

          wrap_deferred 'when the scope has many child scopes' do
            it { expect(subject.and(original)).to be == expected }
          end
        end

        wrap_deferred 'with a non-empty criteria scope' do
          let(:expected) do
            Cuprum::Collections::Scopes::ConjunctionScope.new(
              scopes: [*subject.scopes, original]
            )
          end

          it { expect(subject.and(original)).to be == expected }

          wrap_deferred 'when the scope has many child scopes' do
            it { expect(subject.and(original)).to be == expected }
          end
        end

        wrap_deferred 'with a non-empty disjunction scope' do
          let(:expected) do
            Cuprum::Collections::Scopes::ConjunctionScope.new(
              scopes: [*subject.scopes, original]
            )
          end

          it { expect(subject.and(original)).to be == expected }

          wrap_deferred 'when the scope has many child scopes' do
            it { expect(subject.and(original)).to be == expected }
          end
        end
      end

      describe '#not' do
        include_deferred 'with contexts for composable scopes'

        describe 'with a block' do
          let(:block) { -> { { 'title' => 'A Wizard of Earthsea' } } }
          let(:expected) do
            wrapped = Cuprum::Collections::Scope.new(&block)

            Cuprum::Collections::Scopes::ConjunctionScope.new(
              scopes: [*subject.scopes, wrapped.invert]
            )
          end

          it { expect(subject.not(&block)).to be == expected }

          wrap_deferred 'when the scope has many child scopes' do
            it { expect(subject.not(&block)).to be == expected }
          end
        end

        describe 'with a hash' do
          let(:value) { { 'title' => 'A Wizard of Earthsea' } }
          let(:expected) do
            wrapped = Cuprum::Collections::Scope.new(value)

            Cuprum::Collections::Scopes::ConjunctionScope.new(
              scopes: [*subject.scopes, wrapped.invert]
            )
          end

          it { expect(subject.not(value)).to be == expected }

          wrap_deferred 'when the scope has many child scopes' do
            it { expect(subject.not(value)).to be == expected }
          end
        end

        wrap_deferred 'with an all scope' do
          let(:expected) { Cuprum::Collections::Scopes::NoneScope.new }

          it { expect(subject.not(original)).to be == expected }
        end

        wrap_deferred 'with a none scope' do
          it { expect(subject.not(original)).to be subject }
        end

        wrap_deferred 'with an empty conjunction scope' do
          it { expect(subject.not(original)).to be subject }
        end

        wrap_deferred 'with an empty criteria scope' do
          it { expect(subject.not(original)).to be subject }
        end

        wrap_deferred 'with an empty disjunction scope' do
          it { expect(subject.not(original)).to be subject }
        end

        wrap_deferred 'with a non-empty conjunction scope' do
          let(:expected) do
            Cuprum::Collections::Scopes::ConjunctionScope.new(
              scopes: [*subject.scopes, original.invert]
            )
          end

          it { expect(subject.not(original)).to be == expected }

          wrap_deferred 'when the scope has many child scopes' do
            it { expect(subject.not(original)).to be == expected }
          end
        end

        wrap_deferred 'with a non-empty criteria scope' do
          let(:expected) do
            Cuprum::Collections::Scopes::ConjunctionScope.new(
              scopes: [*subject.scopes, original.invert]
            )
          end

          it { expect(subject.not(original)).to be == expected }

          wrap_deferred 'when the scope has many child scopes' do
            it { expect(subject.not(original)).to be == expected }
          end
        end

        wrap_deferred 'with a non-empty disjunction scope' do
          let(:expected) do
            Cuprum::Collections::Scopes::ConjunctionScope.new(
              scopes: [*subject.scopes, *original.invert.scopes]
            )
          end

          it { expect(subject.not(original)).to be == expected }

          wrap_deferred 'when the scope has many child scopes' do
            it { expect(subject.not(original)).to be == expected }
          end
        end
      end

      describe '#or' do
        include_deferred 'with contexts for composable scopes'

        it 'should define the method' do
          expect(subject)
            .to respond_to(:or)
            .with(0..1).arguments
            .and_a_block
        end

        describe 'with a block' do
          let(:block) { -> { { 'title' => 'A Wizard of Earthsea' } } }
          let(:expected) do
            wrapped = Cuprum::Collections::Scope.new(&block)

            Cuprum::Collections::Scopes::DisjunctionScope.new(
              scopes: [subject, wrapped]
            )
          end

          it { expect(subject.or(&block)).to be == expected }
        end

        describe 'with a hash' do
          let(:value) { { 'title' => 'A Wizard of Earthsea' } }
          let(:expected) do
            wrapped = Cuprum::Collections::Scope.new(value)

            Cuprum::Collections::Scopes::DisjunctionScope.new(
              scopes: [subject, wrapped]
            )
          end

          it { expect(subject.or(value)).to be == expected }
        end

        wrap_deferred 'with an all scope' do
          it { expect(subject.or(original)).to be == original }
        end

        wrap_deferred 'with a none scope' do
          it { expect(subject.or(original)).to be subject }
        end

        wrap_deferred 'with an empty conjunction scope' do
          it { expect(subject.or(original)).to be subject }
        end

        wrap_deferred 'with an empty criteria scope' do
          it { expect(subject.or(original)).to be subject }
        end

        wrap_deferred 'with an empty disjunction scope' do
          it { expect(subject.or(original)).to be subject }
        end

        wrap_deferred 'with a non-empty conjunction scope' do
          let(:expected) do
            Cuprum::Collections::Scopes::DisjunctionScope.new(
              scopes: [subject, original]
            )
          end

          it { expect(subject.or(original)).to be == expected }
        end

        wrap_deferred 'with a non-empty criteria scope' do
          let(:expected) do
            Cuprum::Collections::Scopes::DisjunctionScope.new(
              scopes: [subject, original]
            )
          end

          it { expect(subject.or(original)).to be == expected }
        end

        wrap_deferred 'with a non-empty disjunction scope' do
          let(:expected) do
            Cuprum::Collections::Scopes::DisjunctionScope.new(
              scopes: [subject, *original.scopes]
            )
          end

          it { expect(subject.or(original)).to be == expected }
        end
      end
    end

    deferred_examples 'should filter data by logical AND' do
      deferred_context 'with data' do
        let(:data) do
          Cuprum::Collections::RSpec::Fixtures::BOOKS_FIXTURES
        end
      end

      context 'when the scope has no child scopes' do
        let(:scopes) { [] }

        describe 'with empty data' do
          let(:data) { [] }

          it { expect(filtered_data).to be == [] }
        end

        wrap_deferred 'with data' do
          let(:expected) { data }

          it { expect(filtered_data).to match_array expected }
        end
      end

      context 'when the scope has one child scope' do
        let(:scopes) do
          [
            build_scope({ 'author' => 'J.R.R. Tolkien' })
          ]
        end

        describe 'with empty data' do
          let(:data) { [] }

          it { expect(filtered_data).to be == [] }
        end

        wrap_deferred 'with data' do
          let(:expected) do
            data.select { |item| item['author'] == 'J.R.R. Tolkien' }
          end

          it { expect(filtered_data).to match_array expected }
        end
      end

      context 'when the scope has many child scopes' do
        let(:scopes) do
          [
            build_scope({ 'author' => 'J.R.R. Tolkien' }),
            build_scope({ 'series' => 'The Lord of the Rings' }),
            build_scope do |scope|
              { 'published_at' => scope.less_than('1955-01-01') }
            end
          ]
        end

        describe 'with empty data' do
          let(:data) { [] }

          it { expect(filtered_data).to be == [] }
        end

        wrap_deferred 'with data' do
          let(:expected) do
            data
              .select { |item| item['author'] == 'J.R.R. Tolkien' }
              .select { |item| item['series'] == 'The Lord of the Rings' }
              .select { |item| item['published_at'] < '1955-01-01' }
          end

          it { expect(filtered_data).to match_array expected }
        end
      end
    end
  end
end
