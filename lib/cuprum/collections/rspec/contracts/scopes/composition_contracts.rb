# frozen_string_literal: true

require 'cuprum/collections/queries'
require 'cuprum/collections/rspec/contracts/scopes'
require 'cuprum/collections/scopes/base'
require 'cuprum/collections/scopes/builder'
require 'cuprum/collections/scopes/conjunction_scope'
require 'cuprum/collections/scopes/criteria_scope'
require 'cuprum/collections/scopes/disjunction_scope'
require 'cuprum/collections/scopes/none_scope'

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
        shared_context 'with an all scope' do
          let(:original) do
            Cuprum::Collections::Scopes::AllScope.new
          end
        end

        shared_context 'with a none scope' do
          let(:original) do
            Cuprum::Collections::Scopes::NoneScope.new
          end
        end

        shared_context 'with an empty conjunction scope' do
          let(:original) do
            Cuprum::Collections::Scopes::ConjunctionScope.new(scopes: [])
          end
        end

        shared_context 'with an empty criteria scope' do
          let(:original) do
            Cuprum::Collections::Scopes::CriteriaScope.new(criteria: [])
          end
        end

        shared_context 'with an empty disjunction scope' do
          let(:original) do
            Cuprum::Collections::Scopes::DisjunctionScope.new(scopes: [])
          end
        end

        shared_context 'with a non-empty conjunction scope' do
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
              Cuprum::Collections::Scopes::CriteriaScope.new(criteria: criteria)

            Cuprum::Collections::Scopes::ConjunctionScope.new(scopes: [wrapped])
          end
        end

        shared_examples 'with a non-empty criteria scope' do
          let(:original) do
            operators = Cuprum::Collections::Queries::Operators
            criteria  = [
              [
                'category',
                operators::EQUAL,
                'Science Fiction and Fantasy'
              ]
            ]

            Cuprum::Collections::Scopes::CriteriaScope.new(criteria: criteria)
          end
        end

        shared_context 'with a non-empty disjunction scope' do
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
              Cuprum::Collections::Scopes::CriteriaScope.new(criteria: criteria)

            Cuprum::Collections::Scopes::DisjunctionScope.new(scopes: [wrapped])
          end
        end

        describe '#and' do
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
            let(:expected) do
              wrapped = Cuprum::Collections::Scope.new(&block)

              Cuprum::Collections::Scopes::ConjunctionScope.new(
                scopes: [subject, wrapped]
              )
            end

            it { expect(subject.and(&block)).to be == expected }
          end

          describe 'with a hash' do
            let(:value) { { 'title' => 'A Wizard of Earthsea' } }
            let(:expected) do
              wrapped = Cuprum::Collections::Scope.new(value)

              Cuprum::Collections::Scopes::ConjunctionScope.new(
                scopes: [subject, wrapped]
              )
            end

            it { expect(subject.and(value)).to be == expected }
          end

          wrap_context 'with an all scope' do
            it { expect(subject.and(original)).to be subject }
          end

          wrap_context 'with a none scope' do
            it { expect(subject.and(original)).to be == original }
          end

          wrap_context 'with an empty conjunction scope' do
            it { expect(subject.and(original)).to be subject }
          end

          wrap_context 'with an empty criteria scope' do
            it { expect(subject.and(original)).to be subject }
          end

          wrap_context 'with an empty disjunction scope' do
            it { expect(subject.and(original)).to be subject }
          end

          wrap_context 'with a non-empty conjunction scope' do
            let(:expected) do
              Cuprum::Collections::Scopes::ConjunctionScope.new(
                scopes: [subject, *original.scopes]
              )
            end

            it { expect(subject.and(original)).to be == expected }
          end

          wrap_context 'with a non-empty criteria scope' do
            let(:expected) do
              Cuprum::Collections::Scopes::ConjunctionScope.new(
                scopes: [subject, original]
              )
            end

            it { expect(subject.and(original)).to be == expected }
          end

          wrap_context 'with a non-empty disjunction scope' do
            let(:expected) do
              Cuprum::Collections::Scopes::ConjunctionScope.new(
                scopes: [subject, original]
              )
            end

            it { expect(subject.and(original)).to be == expected }
          end
        end

        describe '#not' do
          it 'should define the method' do
            expect(subject)
              .to respond_to(:not)
              .with(0..1).arguments
              .and_a_block
          end

          next if except.include?(:not)

          describe 'with a block' do
            let(:block) { -> { { 'title' => 'A Wizard of Earthsea' } } }
            let(:block) { -> { { 'title' => 'A Wizard of Earthsea' } } }
            let(:expected) do
              wrapped = Cuprum::Collections::Scope.new(&block)

              Cuprum::Collections::Scopes::ConjunctionScope.new(
                scopes: [subject, wrapped.invert]
              )
            end

            it { expect(subject.not(&block)).to be == expected }
          end

          describe 'with a hash' do
            let(:value)  { { 'title' => 'A Wizard of Earthsea' } }
            let(:expected) do
              wrapped = Cuprum::Collections::Scope.new(value)

              Cuprum::Collections::Scopes::ConjunctionScope.new(
                scopes: [subject, wrapped.invert]
              )
            end

            it { expect(subject.not(value)).to be == expected }
          end

          wrap_context 'with an all scope' do
            let(:expected) { Cuprum::Collections::Scopes::NoneScope.new }

            it { expect(subject.not(original)).to be == expected }
          end

          wrap_context 'with a none scope' do
            it { expect(subject.not(original)).to be subject }
          end

          wrap_context 'with an empty conjunction scope' do
            it { expect(subject.not(original)).to be subject }
          end

          wrap_context 'with an empty criteria scope' do
            it { expect(subject.not(original)).to be subject }
          end

          wrap_context 'with an empty disjunction scope' do
            it { expect(subject.not(original)).to be subject }
          end

          wrap_context 'with a non-empty conjunction scope' do
            let(:expected) do
              Cuprum::Collections::Scopes::ConjunctionScope.new(
                scopes: [subject, original.invert]
              )
            end

            it { expect(subject.not(original)).to be == expected }
          end

          wrap_context 'with a non-empty criteria scope' do
            let(:expected) do
              Cuprum::Collections::Scopes::ConjunctionScope.new(
                scopes: [subject, original.invert]
              )
            end

            it { expect(subject.not(original)).to be == expected }
          end

          wrap_context 'with a non-empty disjunction scope' do
            let(:expected) do
              Cuprum::Collections::Scopes::ConjunctionScope.new(
                scopes: [subject, *original.invert.scopes]
              )
            end

            it { expect(subject.not(original)).to be == expected }
          end
        end

        describe '#or' do
          it 'should define the method' do
            expect(subject)
              .to respond_to(:or)
              .with(0..1).arguments
              .and_a_block
          end

          next if except.include?(:or)

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

          wrap_context 'with an all scope' do
            it { expect(subject.or(original)).to be == original }
          end

          wrap_context 'with a none scope' do
            it { expect(subject.or(original)).to be subject }
          end

          wrap_context 'with an empty conjunction scope' do
            it { expect(subject.or(original)).to be subject }
          end

          wrap_context 'with an empty criteria scope' do
            it { expect(subject.or(original)).to be subject }
          end

          wrap_context 'with an empty disjunction scope' do
            it { expect(subject.or(original)).to be subject }
          end

          wrap_context 'with a non-empty conjunction scope' do
            let(:expected) do
              Cuprum::Collections::Scopes::DisjunctionScope.new(
                scopes: [subject, original]
              )
            end

            it { expect(subject.or(original)).to be == expected }
          end

          wrap_context 'with a non-empty criteria scope' do
            let(:expected) do
              Cuprum::Collections::Scopes::DisjunctionScope.new(
                scopes: [subject, original]
              )
            end

            it { expect(subject.or(original)).to be == expected }
          end

          wrap_context 'with a non-empty disjunction scope' do
            let(:expected) do
              Cuprum::Collections::Scopes::DisjunctionScope.new(
                scopes: [subject, *original.scopes]
              )
            end

            it { expect(subject.or(original)).to be == expected }
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

          wrap_context 'with an all scope' do
            it { expect(subject.and(original)).to be subject }
          end

          wrap_context 'with a none scope' do
            it { expect(subject.and(original)).to be == original }
          end

          wrap_context 'with an empty conjunction scope' do
            it { expect(subject.and(original)).to be subject }

            wrap_context 'when the scope has many child scopes' do
              it { expect(subject.and(original)).to be subject }
            end
          end

          wrap_context 'with an empty criteria scope' do
            it { expect(subject.and(original)).to be subject }
          end

          wrap_context 'with an empty disjunction scope' do
            it { expect(subject.and(original)).to be subject }
          end

          wrap_context 'with a non-empty conjunction scope' do
            let(:expected) do
              Cuprum::Collections::Scopes::ConjunctionScope.new(
                scopes: [*subject.scopes, *original.scopes]
              )
            end

            it { expect(subject.and(original)).to be == expected }

            wrap_context 'when the scope has many child scopes' do
              it { expect(subject.and(original)).to be == expected }
            end
          end

          wrap_context 'with a non-empty criteria scope' do
            let(:expected) do
              Cuprum::Collections::Scopes::ConjunctionScope.new(
                scopes: [*subject.scopes, original]
              )
            end

            it { expect(subject.and(original)).to be == expected }

            wrap_context 'when the scope has many child scopes' do
              it { expect(subject.and(original)).to be == expected }
            end
          end

          wrap_context 'with a non-empty disjunction scope' do
            let(:expected) do
              Cuprum::Collections::Scopes::ConjunctionScope.new(
                scopes: [*subject.scopes, original]
              )
            end

            it { expect(subject.and(original)).to be == expected }

            wrap_context 'when the scope has many child scopes' do
              it { expect(subject.and(original)).to be == expected }
            end
          end
        end

        describe '#not' do
          describe 'with a block' do
            let(:block) { -> { { 'title' => 'A Wizard of Earthsea' } } }
            let(:expected) do
              wrapped = Cuprum::Collections::Scope.new(&block)

              Cuprum::Collections::Scopes::ConjunctionScope.new(
                scopes: [*subject.scopes, wrapped.invert]
              )
            end

            it { expect(subject.not(&block)).to be == expected }

            wrap_context 'when the scope has many child scopes' do
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

            wrap_context 'when the scope has many child scopes' do
              it { expect(subject.not(value)).to be == expected }
            end
          end

          wrap_context 'with an all scope' do
            let(:expected) { Cuprum::Collections::Scopes::NoneScope.new }

            it { expect(subject.not(original)).to be == expected }
          end

          wrap_context 'with a none scope' do
            it { expect(subject.not(original)).to be subject }
          end

          wrap_context 'with an empty conjunction scope' do
            it { expect(subject.not(original)).to be subject }
          end

          wrap_context 'with an empty criteria scope' do
            it { expect(subject.not(original)).to be subject }
          end

          wrap_context 'with an empty disjunction scope' do
            it { expect(subject.not(original)).to be subject }
          end

          wrap_context 'with a non-empty conjunction scope' do
            let(:expected) do
              Cuprum::Collections::Scopes::ConjunctionScope.new(
                scopes: [*subject.scopes, original.invert]
              )
            end

            it { expect(subject.not(original)).to be == expected }

            wrap_context 'when the scope has many child scopes' do
              it { expect(subject.not(original)).to be == expected }
            end
          end

          wrap_context 'with a non-empty criteria scope' do
            let(:expected) do
              Cuprum::Collections::Scopes::ConjunctionScope.new(
                scopes: [*subject.scopes, original.invert]
              )
            end

            it { expect(subject.not(original)).to be == expected }

            wrap_context 'when the scope has many child scopes' do
              it { expect(subject.not(original)).to be == expected }
            end
          end

          wrap_context 'with a non-empty disjunction scope' do
            let(:expected) do
              Cuprum::Collections::Scopes::ConjunctionScope.new(
                scopes: [*subject.scopes, *original.invert.scopes]
              )
            end

            it { expect(subject.not(original)).to be == expected }

            wrap_context 'when the scope has many child scopes' do
              it { expect(subject.not(original)).to be == expected }
            end
          end
        end
      end
    end

    # Contract validating scope composition for criteria scopes.
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

        include_contract 'should compose scopes', except: %i[and not or]

        describe '#and' do
          describe 'with a block' do
            let(:block) { -> { { 'title' => 'A Wizard of Earthsea' } } }
            let(:expected) do
              operators = Cuprum::Collections::Queries::Operators
              criteria  = [
                [
                  'title',
                  operators::EQUAL,
                  'A Wizard of Earthsea'
                ]
              ]

              Cuprum::Collections::Scopes::CriteriaScope.new(
                criteria: [*self.criteria, *criteria]
              )
            end

            it { expect(subject.and(&block)).to be == expected }

            wrap_context 'when the scope has multiple criteria' do
              it { expect(subject.and(&block)).to be == expected }
            end
          end

          describe 'with a hash' do
            let(:value) { { 'title' => 'A Wizard of Earthsea' } }
            let(:expected) do
              operators = Cuprum::Collections::Queries::Operators
              criteria  = [
                [
                  'title',
                  operators::EQUAL,
                  'A Wizard of Earthsea'
                ]
              ]

              Cuprum::Collections::Scopes::CriteriaScope.new(
                criteria: [*self.criteria, *criteria]
              )
            end

            it { expect(subject.and(value)).to be == expected }

            wrap_context 'when the scope has multiple criteria' do
              it { expect(subject.and(value)).to be == expected }
            end
          end

          wrap_context 'with an all scope' do
            it { expect(subject.and(original)).to be == original }

            wrap_context 'when the scope has multiple criteria' do
              it { expect(subject.and(original)).to be subject }
            end
          end

          wrap_context 'with a none scope' do
            it { expect(subject.and(original)).to be == original }

            wrap_context 'when the scope has multiple criteria' do
              it { expect(subject.and(original)).to be == original }
            end
          end

          wrap_context 'with an empty conjunction scope' do
            it { expect(subject.and(original)).to be subject }

            wrap_context 'when the scope has multiple criteria' do
              it { expect(subject.and(original)).to be subject }
            end
          end

          wrap_context 'with an empty criteria scope' do
            it { expect(subject.and(original)).to be subject }

            wrap_context 'when the scope has multiple criteria' do
              it { expect(subject.and(original)).to be subject }
            end
          end

          context 'with an empty inverted criteria scope' do
            include_context 'with an empty criteria scope'

            let(:inverted) { original.invert }

            it { expect(subject.and(inverted)).to be subject }

            wrap_context 'when the scope has multiple criteria' do
              it { expect(subject.and(original)).to be subject }
            end
          end

          wrap_context 'with an empty disjunction scope' do
            it { expect(subject.and(original)).to be subject }

            wrap_context 'when the scope has multiple criteria' do
              it { expect(subject.and(original)).to be subject }
            end
          end

          wrap_context 'with a non-empty conjunction scope' do
            it { expect(subject.and(original)).to be == original }

            wrap_context 'when the scope has multiple criteria' do
              let(:expected) do
                Cuprum::Collections::Scopes::ConjunctionScope.new(
                  scopes: [subject, *original.scopes]
                )
              end

              it { expect(subject.and(original)).to be == expected }
            end
          end

          wrap_context 'with a non-empty criteria scope' do
            let(:expected) do
              Cuprum::Collections::Scopes::CriteriaScope.new(
                criteria: [*subject.criteria, *original.criteria]
              )
            end

            it { expect(subject.and(original)).to be == expected }

            wrap_context 'when the scope has multiple criteria' do
              it { expect(subject.and(original)).to be == expected }
            end
          end

          context 'with a non-empty inverted criteria scope' do
            include_context 'with a non-empty criteria scope'

            let(:inverted) { original.invert }

            it { expect(subject.and(inverted)).to be == inverted }

            wrap_context 'when the scope has multiple criteria' do
              let(:expected) do
                Cuprum::Collections::Scopes::ConjunctionScope.new(
                  scopes: [subject, inverted]
                )
              end

              it { expect(subject.and(inverted)).to be == expected }
            end
          end

          wrap_context 'with a non-empty disjunction scope' do
            it { expect(subject.and(original)).to be == original }

            wrap_context 'when the scope has multiple criteria' do
              let(:expected) do
                Cuprum::Collections::Scopes::ConjunctionScope.new(
                  scopes: [subject, original]
                )
              end

              it { expect(subject.and(original)).to be == expected }
            end
          end

          wrap_context 'when initialized with inverted: true' do
            describe 'with a block' do
              let(:block) { -> { { 'title' => 'A Wizard of Earthsea' } } }
              let(:expected) do
                Cuprum::Collections::Scope.new(&block)
              end

              it { expect(subject.and(&block)).to be == expected }

              wrap_context 'when the scope has multiple criteria' do
                let(:expected) do
                  wrapped = Cuprum::Collections::Scope.new(&block)

                  Cuprum::Collections::Scopes::ConjunctionScope.new(
                    scopes: [subject, wrapped]
                  )
                end

                it { expect(subject.and(&block)).to be == expected }
              end
            end

            describe 'with a hash' do
              let(:value) { { 'title' => 'A Wizard of Earthsea' } }
              let(:expected) do
                Cuprum::Collections::Scope.new(value)
              end

              it { expect(subject.and(value)).to be == expected }

              wrap_context 'when the scope has multiple criteria' do
                let(:expected) do
                  wrapped = Cuprum::Collections::Scope.new(value)

                  Cuprum::Collections::Scopes::ConjunctionScope.new(
                    scopes: [subject, wrapped]
                  )
                end

                it { expect(subject.and(value)).to be == expected }
              end
            end

            wrap_context 'with an empty criteria scope' do
              it { expect(subject.and(original)).to be subject }

              wrap_context 'when the scope has multiple criteria' do
                it { expect(subject.and(original)).to be subject }
              end
            end

            context 'with an empty inverted criteria scope' do
              include_context 'with an empty criteria scope'

              let(:inverted) { original.invert }

              it { expect(subject.and(inverted)).to be subject }

              wrap_context 'when the scope has multiple criteria' do
                it { expect(subject.and(inverted)).to be subject }
              end
            end

            wrap_context 'with a non-empty criteria scope' do
              it { expect(subject.and(original)).to be == original }

              wrap_context 'when the scope has multiple criteria' do
                let(:expected) do
                  Cuprum::Collections::Scopes::ConjunctionScope.new(
                    scopes: [subject, original]
                  )
                end

                it { expect(subject.and(original)).to be == expected }
              end
            end

            context 'with a non-empty inverted criteria scope' do
              include_context 'with a non-empty criteria scope'

              let(:inverted) { original.invert }

              it { expect(subject.and(inverted)).to be == inverted }

              wrap_context 'when the scope has multiple criteria' do
                let(:expected) do
                  Cuprum::Collections::Scopes::ConjunctionScope.new(
                    scopes: [subject, inverted]
                  )
                end

                it { expect(subject.and(inverted)).to be == expected }
              end
            end
          end
        end

        describe '#not' do
          describe 'with a block' do
            let(:block) { -> { { 'title' => 'A Wizard of Earthsea' } } }
            let(:expected) do
              Cuprum::Collections::Scope.new(&block).invert
            end

            it { expect(subject.not(&block)).to be == expected }

            wrap_context 'when the scope has multiple criteria' do
              let(:expected) do
                wrapped = Cuprum::Collections::Scope.new(&block)

                Cuprum::Collections::Scopes::ConjunctionScope.new(
                  scopes: [subject, wrapped.invert]
                )
              end

              it { expect(subject.not(&block)).to be == expected }
            end
          end

          describe 'with a hash' do
            let(:value) { { 'title' => 'A Wizard of Earthsea' } }
            let(:expected) do
              Cuprum::Collections::Scope.new(value).invert
            end

            it { expect(subject.not(value)).to be == expected }

            wrap_context 'when the scope has multiple criteria' do
              let(:expected) do
                wrapped = Cuprum::Collections::Scope.new(value)

                Cuprum::Collections::Scopes::ConjunctionScope.new(
                  scopes: [subject, wrapped.invert]
                )
              end

              it { expect(subject.not(value)).to be == expected }
            end
          end

          wrap_context 'with an all scope' do
            it { expect(subject.not(original)).to be == original.invert }

            wrap_context 'when the scope has multiple criteria' do
              it { expect(subject.not(original)).to be == original.invert }
            end
          end

          wrap_context 'with a none scope' do
            it { expect(subject.not(original)).to be == original.invert }

            wrap_context 'when the scope has multiple criteria' do
              it { expect(subject.not(original)).to be subject }
            end
          end

          wrap_context 'with an empty conjunction scope' do
            it { expect(subject.not(original)).to be subject }

            wrap_context 'when the scope has multiple criteria' do
              it { expect(subject.not(original)).to be subject }
            end
          end

          wrap_context 'with an empty criteria scope' do
            it { expect(subject.not(original)).to be subject }

            wrap_context 'when the scope has multiple criteria' do
              it { expect(subject.not(original)).to be subject }
            end
          end

          context 'with an empty inverted criteria scope' do
            include_context 'with an empty criteria scope'

            let(:inverted) { original.invert }

            it { expect(subject.not(inverted)).to be subject }

            wrap_context 'when the scope has multiple criteria' do
              it { expect(subject.not(original)).to be subject }
            end
          end

          wrap_context 'with an empty disjunction scope' do
            it { expect(subject.not(original)).to be subject }

            wrap_context 'when the scope has multiple criteria' do
              it { expect(subject.not(original)).to be subject }
            end
          end

          wrap_context 'with a non-empty conjunction scope' do
            it { expect(subject.not(original)).to be == original.invert }

            wrap_context 'when the scope has multiple criteria' do
              let(:expected) do
                Cuprum::Collections::Scopes::ConjunctionScope.new(
                  scopes: [subject, original.invert]
                )
              end

              it { expect(subject.not(original)).to be == expected }
            end
          end

          wrap_context 'with a non-empty criteria scope' do
            it { expect(subject.not(original)).to be == original.invert }

            wrap_context 'when the scope has multiple criteria' do
              let(:expected) do
                Cuprum::Collections::Scopes::ConjunctionScope.new(
                  scopes: [subject, original.invert]
                )
              end

              it { expect(subject.not(original)).to be == expected }
            end
          end

          context 'with a non-empty inverted criteria scope' do
            include_context 'with a non-empty criteria scope'

            let(:inverted) { original.invert }

            it { expect(subject.not(inverted)).to be == original }

            wrap_context 'when the scope has multiple criteria' do
              let(:expected) do
                Cuprum::Collections::Scopes::CriteriaScope.new(
                  criteria: [*subject.criteria, *original.criteria]
                )
              end

              it { expect(subject.not(inverted)).to be == expected }
            end
          end

          wrap_context 'with a non-empty disjunction scope' do
            it { expect(subject.not(original)).to be == original.invert }

            wrap_context 'when the scope has multiple criteria' do
              let(:expected) do
                Cuprum::Collections::Scopes::ConjunctionScope.new(
                  scopes: [subject, *original.invert.scopes]
                )
              end

              it { expect(subject.not(original)).to be == expected }
            end
          end

          wrap_context 'when initialized with inverted: true' do
            describe 'with a block' do
              let(:block) { -> { { 'title' => 'A Wizard of Earthsea' } } }
              let(:expected) do
                Cuprum::Collections::Scope.new(&block).invert
              end

              it { expect(subject.not(&block)).to be == expected }

              wrap_context 'when the scope has multiple criteria' do
                let(:expected) do
                  wrapped = Cuprum::Collections::Scope.new(&block)

                  Cuprum::Collections::Scopes::ConjunctionScope.new(
                    scopes: [subject, wrapped.invert]
                  )
                end

                it { expect(subject.not(&block)).to be == expected }
              end
            end

            describe 'with a hash' do
              let(:value) { { 'title' => 'A Wizard of Earthsea' } }
              let(:expected) do
                Cuprum::Collections::Scope.new(value).invert
              end

              it { expect(subject.not(value)).to be == expected }

              wrap_context 'when the scope has multiple criteria' do
                let(:expected) do
                  wrapped = Cuprum::Collections::Scope.new(value)

                  Cuprum::Collections::Scopes::ConjunctionScope.new(
                    scopes: [subject, wrapped.invert]
                  )
                end

                it { expect(subject.not(value)).to be == expected }
              end
            end

            wrap_context 'with an all scope' do
              it { expect(subject.not(original)).to be == original.invert }

              wrap_context 'when the scope has multiple criteria' do
                it { expect(subject.not(original)).to be == original.invert }
              end
            end

            wrap_context 'with a none scope' do
              it { expect(subject.not(original)).to be == original.invert }

              wrap_context 'when the scope has multiple criteria' do
                it { expect(subject.not(original)).to be subject }
              end
            end

            wrap_context 'with an empty conjunction scope' do
              it { expect(subject.not(original)).to be subject }

              wrap_context 'when the scope has multiple criteria' do
                it { expect(subject.not(original)).to be subject }
              end
            end

            wrap_context 'with an empty criteria scope' do
              it { expect(subject.not(original)).to be subject }

              wrap_context 'when the scope has multiple criteria' do
                it { expect(subject.not(original)).to be subject }
              end
            end

            context 'with an empty inverted criteria scope' do
              include_context 'with an empty criteria scope'

              let(:inverted) { original.invert }

              it { expect(subject.not(inverted)).to be subject }

              wrap_context 'when the scope has multiple criteria' do
                it { expect(subject.not(original)).to be subject }
              end
            end

            wrap_context 'with an empty disjunction scope' do
              it { expect(subject.not(original)).to be subject }

              wrap_context 'when the scope has multiple criteria' do
                it { expect(subject.not(original)).to be subject }
              end
            end

            wrap_context 'with a non-empty conjunction scope' do
              it { expect(subject.not(original)).to be == original.invert }

              wrap_context 'when the scope has multiple criteria' do
                let(:expected) do
                  Cuprum::Collections::Scopes::ConjunctionScope.new(
                    scopes: [subject, original.invert]
                  )
                end

                it { expect(subject.not(original)).to be == expected }
              end
            end

            wrap_context 'with a non-empty criteria scope' do
              it { expect(subject.not(original)).to be == original.invert }

              wrap_context 'when the scope has multiple criteria' do
                let(:expected) do
                  Cuprum::Collections::Scopes::ConjunctionScope.new(
                    scopes: [subject, original.invert]
                  )
                end

                it { expect(subject.not(original)).to be == expected }
              end
            end

            context 'with a non-empty inverted criteria scope' do
              include_context 'with a non-empty criteria scope'

              let(:inverted) { original.invert }

              it { expect(subject.not(inverted)).to be == original }

              wrap_context 'when the scope has multiple criteria' do
                let(:expected) do
                  Cuprum::Collections::Scopes::ConjunctionScope.new(
                    scopes: [subject, original]
                  )
                end

                it { expect(subject.not(inverted)).to be == expected }
              end
            end

            wrap_context 'with a non-empty disjunction scope' do
              it { expect(subject.not(original)).to be == original.invert }

              wrap_context 'when the scope has multiple criteria' do
                let(:expected) do
                  Cuprum::Collections::Scopes::ConjunctionScope.new(
                    scopes: [subject, *original.invert.scopes]
                  )
                end

                it { expect(subject.not(original)).to be == expected }
              end
            end
          end
        end

        describe '#or' do
          describe 'with a block' do
            let(:block) { -> { { 'title' => 'A Wizard of Earthsea' } } }
            let(:expected) do
              Cuprum::Collections::Scope.new(&block)
            end

            it { expect(subject.or(&block)).to be == expected }

            wrap_context 'when the scope has multiple criteria' do
              let(:expected) do
                Cuprum::Collections::Scopes::DisjunctionScope.new(
                  scopes: [subject, super()]
                )
              end

              it { expect(subject.or(&block)).to be == expected }
            end
          end

          describe 'with a hash' do
            let(:value) { { 'title' => 'A Wizard of Earthsea' } }
            let(:expected) do
              Cuprum::Collections::Scope.new(value)
            end

            it { expect(subject.or(value)).to be == expected }

            wrap_context 'when the scope has multiple criteria' do
              let(:expected) do
                Cuprum::Collections::Scopes::DisjunctionScope.new(
                  scopes: [subject, super()]
                )
              end

              it { expect(subject.or(value)).to be == expected }
            end
          end

          wrap_context 'with an all scope' do
            it { expect(subject.or(original)).to be == original }

            wrap_context 'when the scope has multiple criteria' do
              it { expect(subject.or(original)).to be == original }
            end
          end

          wrap_context 'with a none scope' do
            it { expect(subject.or(original)).to be subject }

            wrap_context 'when the scope has multiple criteria' do
              it { expect(subject.or(original)).to be subject }
            end
          end

          wrap_context 'with an empty conjunction scope' do
            it { expect(subject.or(original)).to be subject }

            wrap_context 'when the scope has multiple criteria' do
              it { expect(subject.or(original)).to be subject }
            end
          end

          wrap_context 'with an empty criteria scope' do
            it { expect(subject.or(original)).to be subject }

            wrap_context 'when the scope has multiple criteria' do
              it { expect(subject.or(original)).to be subject }
            end
          end

          wrap_context 'with an empty disjunction scope' do
            it { expect(subject.or(original)).to be subject }

            wrap_context 'when the scope has multiple criteria' do
              it { expect(subject.or(original)).to be subject }
            end
          end

          wrap_context 'with a non-empty conjunction scope' do
            it { expect(subject.or(original)).to be == original }

            wrap_context 'when the scope has multiple criteria' do
              let(:expected) do
                Cuprum::Collections::Scopes::DisjunctionScope.new(
                  scopes: [subject, original]
                )
              end

              it { expect(subject.or(original)).to be == expected }
            end
          end

          wrap_context 'with a non-empty criteria scope' do
            it { expect(subject.or(original)).to be == original }

            wrap_context 'when the scope has multiple criteria' do
              let(:expected) do
                Cuprum::Collections::Scopes::DisjunctionScope.new(
                  scopes: [subject, original]
                )
              end

              it { expect(subject.or(original)).to be == expected }
            end
          end

          wrap_context 'with a non-empty disjunction scope' do
            it { expect(subject.or(original)).to be == original }

            wrap_context 'when the scope has multiple criteria' do
              let(:expected) do
                Cuprum::Collections::Scopes::DisjunctionScope.new(
                  scopes: [subject, *original.scopes]
                )
              end

              it { expect(subject.or(original)).to be == expected }
            end
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
          describe 'with a block' do
            let(:block) { -> { { 'title' => 'A Wizard of Earthsea' } } }
            let(:expected) do
              wrapped = Cuprum::Collections::Scope.new(&block)

              Cuprum::Collections::Scopes::DisjunctionScope.new(
                scopes: [*subject.scopes, wrapped]
              )
            end

            it { expect(subject.or(&block)).to be == expected }
          end

          describe 'with a hash' do
            let(:value) { { 'title' => 'A Wizard of Earthsea' } }
            let(:expected) do
              wrapped = Cuprum::Collections::Scope.new(value)

              Cuprum::Collections::Scopes::DisjunctionScope.new(
                scopes: [*subject.scopes, wrapped]
              )
            end

            it { expect(subject.or(value)).to be == expected }
          end

          wrap_context 'with an all scope' do
            it { expect(subject.or(original)).to be == original }
          end

          wrap_context 'with a none scope' do
            it { expect(subject.or(original)).to be subject }
          end

          wrap_context 'with an empty conjunction scope' do
            it { expect(subject.or(original)).to be subject }
          end

          wrap_context 'with an empty criteria scope' do
            it { expect(subject.or(original)).to be subject }
          end

          wrap_context 'with an empty disjunction scope' do
            it { expect(subject.or(original)).to be subject }
          end

          wrap_context 'with a non-empty conjunction scope' do
            let(:expected) do
              Cuprum::Collections::Scopes::DisjunctionScope.new(
                scopes: [*subject.scopes, original]
              )
            end

            it { expect(subject.or(original)).to be == expected }
          end

          wrap_context 'with a non-empty criteria scope' do
            let(:expected) do
              Cuprum::Collections::Scopes::DisjunctionScope.new(
                scopes: [*subject.scopes, original]
              )
            end

            it { expect(subject.or(original)).to be == expected }
          end

          wrap_context 'with a non-empty disjunction scope' do
            let(:expected) do
              Cuprum::Collections::Scopes::DisjunctionScope.new(
                scopes: [*subject.scopes, *original.scopes]
              )
            end

            it { expect(subject.or(original)).to be == expected }

            wrap_context 'when the scope has many child scopes' do
              it { expect(subject.or(original)).to be == expected }
            end
          end
        end
      end
    end
  end
end
