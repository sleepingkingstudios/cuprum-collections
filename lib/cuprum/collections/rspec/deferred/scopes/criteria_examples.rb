# frozen_string_literal: true

require 'rspec/sleeping_king_studios/deferred'

require 'cuprum/collections/rspec/deferred/scope_examples'
require 'cuprum/collections/rspec/deferred/scopes'
require 'cuprum/collections/rspec/deferred/scopes/composition_examples'
require 'cuprum/collections/rspec/deferred/scopes/parser_examples'
require 'cuprum/collections/rspec/fixtures'

module Cuprum::Collections::RSpec::Deferred::Scopes
  # Deferred examples for asserting on Criteria scopes.
  module CriteriaExamples
    include RSpec::SleepingKingStudios::Deferred::Provider
    include Cuprum::Collections::RSpec::Deferred::ScopeExamples
    include Cuprum::Collections::RSpec::Deferred::Scopes::CompositionExamples
    include Cuprum::Collections::RSpec::Deferred::Scopes::ParserExamples

    deferred_examples 'should implement the CriteriaScope methods' \
    do |**deferred_options|
      deferred_context 'when initialized with inverted: true' do
        let(:constructor_options) { super().merge(inverted: true) }
      end

      deferred_context 'when the scope has multiple criteria' do
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

      deferred_context 'with criteria' do
        let(:criteria) do
          operators = Cuprum::Collections::Queries::Operators

          [
            ['title',  operators::EQUAL, 'Gideon the Ninth'],
            ['author', operators::EQUAL, 'Tamsyn Muir']
          ]
        end
      end

      let(:criteria) { [] }

      include_deferred 'should implement the Scope methods', invertible: true

      include_deferred 'should compose scopes as a CriteriaScope'

      describe '.new' do
        next if deferred_options.fetch(:skip_constructor, false)

        it 'should define the constructor' do
          expect(described_class)
            .to be_constructible
            .with(0).arguments
            .and_keywords(:criteria, :inverted)
            .and_any_keywords
        end
      end

      describe '.build' do
        let(:value) { { 'title' => 'The Word for World is Forest' } }

        define_method :parse_criteria do |*args, &block|
          return described_class.build(&block).criteria if args.empty?

          described_class.build(args.first, &block).criteria
        end

        it 'should define class method' do
          expect(described_class)
            .to respond_to(:build)
            .with(0..1).arguments
            .and_a_block
        end

        it { expect(described_class.build(value)).to be_a described_class }

        include_deferred 'should parse Scope criteria'
      end

      describe '.parse' do
        define_method :parse_criteria do |*args, &block|
          return described_class.parse(&block) if args.empty?

          described_class.parse(args.first, &block)
        end

        it 'should define class method' do
          expect(described_class)
            .to respond_to(:parse)
            .with(0..1).arguments
            .and_a_block
        end

        include_deferred 'should parse Scope criteria'
      end

      describe '#==' do
        next if deferred_options.fetch(:skip_equality, false)

        describe 'with a scope with the same class' do
          let(:other_criteria) { [] }
          let(:other_inverted) { false }
          let(:other) do
            described_class.new(
              criteria: other_criteria,
              inverted: other_inverted
            )
          end

          describe 'with empty criteria' do
            let(:other_criteria) { [] }

            it { expect(subject == other).to be true }

            describe 'with inverted: true' do
              let(:other_inverted) { true }

              it { expect(subject == other).to be false }
            end
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

            it { expect(subject == other).to be false }

            describe 'with inverted: true' do
              let(:other_inverted) { true }

              it { expect(subject == other).to be false }
            end
          end

          wrap_deferred 'with criteria' do
            describe 'with empty criteria' do
              let(:other_criteria) { [] }

              it { expect(subject == other).to be false }

              describe 'with inverted: true' do
                let(:other_inverted) { true }

                it { expect(subject == other).to be false }
              end
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

              it { expect(subject == other).to be false }

              describe 'with inverted: true' do
                let(:other_inverted) { true }

                it { expect(subject == other).to be false }
              end
            end

            describe 'with matching criteria' do
              let(:other_criteria) { subject.criteria }

              it { expect(subject == other).to be true }

              describe 'with inverted: true' do
                let(:other_inverted) { true }

                it { expect(subject == other).to be false }
              end
            end
          end

          wrap_deferred 'when initialized with inverted: true' do
            describe 'with empty criteria' do
              let(:other_criteria) { [] }

              it { expect(subject == other).to be false }

              describe 'with inverted: true' do
                let(:other_inverted) { true }

                it { expect(subject == other).to be true }
              end
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

              it { expect(subject == other).to be false }

              describe 'with inverted: true' do
                let(:other_inverted) { true }

                it { expect(subject == other).to be false }
              end
            end

            wrap_deferred 'with criteria' do
              describe 'with empty criteria' do
                let(:other_criteria) { [] }

                it { expect(subject == other).to be false }

                describe 'with inverted: true' do
                  let(:other_inverted) { true }

                  it { expect(subject == other).to be false }
                end
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

                it { expect(subject == other).to be false }

                describe 'with inverted: true' do
                  let(:other_inverted) { true }

                  it { expect(subject == other).to be false }
                end
              end

              describe 'with matching criteria' do
                let(:other_criteria) { subject.criteria }

                it { expect(subject == other).to be false }

                describe 'with inverted: true' do
                  let(:other_inverted) { true }

                  it { expect(subject == other).to be true }
                end
              end
            end
          end
        end

        describe 'with a scope with the same type' do
          let(:other_criteria) { [] }
          let(:other_inverted) { false }
          let(:other) do
            described_class.new(
              criteria: other_criteria,
              inverted: other_inverted
            )
          end

          example_class 'Spec::CustomScope',
            Cuprum::Collections::Scopes::Base \
          do |klass|
            klass.include Cuprum::Collections::Scopes::Criteria
          end

          describe 'with empty criteria' do
            let(:other_criteria) { [] }

            it { expect(subject == other).to be true }

            describe 'with inverted: true' do
              let(:other_inverted) { true }

              it { expect(subject == other).to be false }
            end
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

            it { expect(subject == other).to be false }

            describe 'with inverted: true' do
              let(:other_inverted) { true }

              it { expect(subject == other).to be false }
            end
          end

          wrap_deferred 'with criteria' do
            describe 'with empty criteria' do
              let(:other_criteria) { [] }

              it { expect(subject == other).to be false }

              describe 'with inverted: true' do
                let(:other_inverted) { true }

                it { expect(subject == other).to be false }
              end
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

              it { expect(subject == other).to be false }

              describe 'with inverted: true' do
                let(:other_inverted) { true }

                it { expect(subject == other).to be false }
              end
            end

            describe 'with matching criteria' do
              let(:other_criteria) { subject.criteria }

              it { expect(subject == other).to be true }

              describe 'with inverted: true' do
                let(:other_inverted) { true }

                it { expect(subject == other).to be false }
              end
            end
          end

          wrap_deferred 'when initialized with inverted: true' do
            describe 'with empty criteria' do
              let(:other_criteria) { [] }

              it { expect(subject == other).to be false }

              describe 'with inverted: true' do
                let(:other_inverted) { true }

                it { expect(subject == other).to be true }
              end
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

              it { expect(subject == other).to be false }

              describe 'with inverted: true' do
                let(:other_inverted) { true }

                it { expect(subject == other).to be false }
              end
            end

            wrap_deferred 'with criteria' do
              describe 'with empty criteria' do
                let(:other_criteria) { [] }

                it { expect(subject == other).to be false }

                describe 'with inverted: true' do
                  let(:other_inverted) { true }

                  it { expect(subject == other).to be false }
                end
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

                it { expect(subject == other).to be false }

                describe 'with inverted: true' do
                  let(:other_inverted) { true }

                  it { expect(subject == other).to be false }
                end
              end

              describe 'with matching criteria' do
                let(:other_criteria) { subject.criteria }

                it { expect(subject == other).to be false }

                describe 'with inverted: true' do
                  let(:other_inverted) { true }

                  it { expect(subject == other).to be true }
                end
              end
            end
          end
        end
      end

      describe '#as_json' do
        let(:expected) do
          {
            'criteria' => subject.criteria,
            'inverted' => subject.inverted?,
            'type'     => subject.type
          }
        end

        it { expect(subject.as_json).to be == expected }

        wrap_deferred 'when initialized with inverted: true' do
          it { expect(subject.as_json).to be == expected }
        end

        wrap_deferred 'with criteria' do
          it { expect(subject.as_json).to be == expected }

          wrap_deferred 'when initialized with inverted: true' do
            it { expect(subject.as_json).to be == expected }
          end
        end
      end

      describe '#call' do
        next if deferred_options.fetch(:abstract, false)

        it { expect(subject).to respond_to(:call) }

        include_deferred 'should filter data by criteria'

        context 'when the scope is inverted' do
          subject { super().invert }

          let(:matching_data) { data - filtered_data }

          include_deferred 'should filter data by criteria',
            ignore_invalid: true,
            inverted:       true
        end
      end

      describe '#criteria' do
        include_examples 'should define reader', :criteria, -> { criteria }

        wrap_deferred 'with criteria' do
          it { expect(subject.criteria).to be == criteria }
        end
      end

      describe '#empty?' do
        include_examples 'should define predicate', :empty?, true

        wrap_deferred 'with criteria' do
          it { expect(subject.empty?).to be false }
        end
      end

      describe '#invert' do
        shared_examples 'should invert the criteria' do
          it { expect(copy.criteria).to be == [] }

          context 'when the scope has an equality criterion' do
            let(:criteria) do
              described_class.parse({
                'title' => 'The Word for World is Forest'
              })
            end
            let(:expected) do
              operators = Cuprum::Collections::Queries::Operators

              [
                [
                  'title',
                  operators::NOT_EQUAL,
                  'The Word for World is Forest'
                ]
              ]
            end

            it { expect(copy.criteria).to be == expected }
          end

          context 'when the scope has a greater than criterion' do
            let(:criteria) do
              described_class.parse do |scope|
                { 'published_at' => scope.greater_than('1972-03-13') }
              end
            end
            let(:expected) do
              operators = Cuprum::Collections::Queries::Operators

              [
                [
                  'published_at',
                  operators::LESS_THAN_OR_EQUAL_TO,
                  '1972-03-13'
                ]
              ]
            end

            it { expect(copy.criteria).to be == expected }
          end

          context 'when the scope has a greater than or equal to criterion' do
            let(:criteria) do
              described_class.parse do |scope|
                {
                  'published_at' => scope.greater_than_or_equal_to(
                    '1972-03-13'
                  )
                }
              end
            end
            let(:expected) do
              operators = Cuprum::Collections::Queries::Operators

              [
                [
                  'published_at',
                  operators::LESS_THAN,
                  '1972-03-13'
                ]
              ]
            end

            it { expect(copy.criteria).to be == expected }
          end

          context 'when the scope has a less than criterion' do
            let(:criteria) do
              described_class.parse do |scope|
                { 'published_at' => scope.less_than('1972-03-13') }
              end
            end
            let(:expected) do
              operators = Cuprum::Collections::Queries::Operators

              [
                [
                  'published_at',
                  operators::GREATER_THAN_OR_EQUAL_TO,
                  '1972-03-13'
                ]
              ]
            end

            it { expect(copy.criteria).to be == expected }
          end

          context 'when the scope has a less than or equal to criterion' do
            let(:criteria) do
              described_class.parse do |scope|
                {
                  'published_at' => scope.less_than_or_equal_to(
                    '1972-03-13'
                  )
                }
              end
            end
            let(:expected) do
              operators = Cuprum::Collections::Queries::Operators

              [
                [
                  'published_at',
                  operators::GREATER_THAN,
                  '1972-03-13'
                ]
              ]
            end

            it { expect(copy.criteria).to be == expected }
          end

          context 'when the scope has a not equal criterion' do
            let(:criteria) do
              described_class.parse do |scope|
                { 'author' => scope.not_equal('J.R.R. Tolkien') }
              end
            end
            let(:expected) do
              operators = Cuprum::Collections::Queries::Operators

              [
                [
                  'author',
                  operators::EQUAL,
                  'J.R.R. Tolkien'
                ]
              ]
            end

            it { expect(copy.criteria).to be == expected }
          end

          context 'when the scope has a not one of criterion' do
            let(:criteria) do
              described_class.parse do |scope|
                titles = ['The Fellowship Of The Ring', 'The Two Towers']

                { 'title' => scope.not_one_of(titles) }
              end
            end
            let(:expected) do
              operators = Cuprum::Collections::Queries::Operators

              [
                [
                  'title',
                  operators::ONE_OF,
                  ['The Fellowship Of The Ring', 'The Two Towers']
                ]
              ]
            end

            it { expect(copy.criteria).to be == expected }
          end

          context 'when the scope has a one of criterion' do
            let(:criteria) do
              described_class.parse do |scope|
                titles = ['The Fellowship Of The Ring', 'The Two Towers']

                { 'title' => scope.one_of(titles) }
              end
            end
            let(:expected) do
              operators = Cuprum::Collections::Queries::Operators

              [
                [
                  'title',
                  operators::NOT_ONE_OF,
                  ['The Fellowship Of The Ring', 'The Two Towers']
                ]
              ]
            end

            it { expect(copy.criteria).to be == expected }
          end

          context 'when the scope has multiple criteria' do
            let(:criteria) do
              described_class.parse do |scope|
                titles = ['The Fellowship Of The Ring', 'The Two Towers']

                {
                  'author' => 'J.R.R. Tolkien',
                  'title'  => scope.not_one_of(titles)
                }
              end
            end
            let(:expected) do
              operators = Cuprum::Collections::Queries::Operators

              [
                [
                  'author',
                  operators::NOT_EQUAL,
                  'J.R.R. Tolkien'
                ],
                [
                  'title',
                  operators::ONE_OF,
                  ['The Fellowship Of The Ring', 'The Two Towers']
                ]
              ]
            end

            it { expect(copy.criteria).to be == expected }
          end

          context 'when initialized with uninvertible criteria' do
            next if deferred_options.fetch(:ignore_uninvertible, false)

            let(:criteria) do
              [
                [
                  'title',
                  'random',
                  nil
                ]
              ]
            end
            let(:error_class) do
              Cuprum::Collections::Queries::UninvertibleOperatorException
            end
            let(:error_message) { 'uninvertible operator "random"' }

            it 'should raise an exception' do
              expect { subject.invert }
                .to raise_error error_class, error_message
            end
          end
        end

        let(:copy) { subject.invert }

        it { expect(copy).to be_a described_class }

        it { expect(copy.inverted?).to be true }

        include_examples 'should invert the criteria'

        wrap_deferred 'when initialized with inverted: true' do
          it { expect(copy).to be_a described_class }

          it { expect(copy.inverted?).to be false }

          include_examples 'should invert the criteria'
        end
      end

      describe '#inverted?' do
        include_examples 'should define predicate', :inverted?, false

        wrap_deferred 'when initialized with inverted: true' do
          it { expect(subject.inverted?).to be true }
        end
      end

      describe '#type' do
        include_examples 'should define reader', :type, :criteria
      end

      describe '#with_criteria' do
        let(:new_criteria) { ['author', 'eq', 'Ursula K. LeGuin'] }

        it { expect(subject).to respond_to(:with_criteria).with(1).argument }

        it 'should return a scope' do
          expect(subject.with_criteria(new_criteria)).to be_a described_class
        end

        it "should not change the original scope's criteria" do
          expect { subject.with_criteria(new_criteria) }
            .not_to change(subject, :criteria)
        end

        it "should set the copied scope's criteria" do
          expect(subject.with_criteria(new_criteria).criteria)
            .to be == new_criteria
        end

        it 'should return an uninverted scope' do
          expect(subject.with_criteria(new_criteria).inverted?).to be false
        end

        wrap_deferred 'with criteria' do
          it "should not change the original scope's criteria" do
            expect { subject.with_criteria(new_criteria) }
              .not_to change(subject, :criteria)
          end

          it "should set the copied scope's criteria" do
            expect(subject.with_criteria(new_criteria).criteria)
              .to be == new_criteria
          end
        end

        wrap_deferred 'when initialized with inverted: true' do
          it 'should return an inverted scope' do
            expect(subject.with_criteria(new_criteria).inverted?).to be true
          end
        end
      end
    end

    deferred_examples 'should compose scopes as a CriteriaScope' do
      describe '#and' do
        include_deferred 'with contexts for composable scopes'

        describe 'with a block' do
          let(:block) { ->(_) { { 'title' => 'A Wizard of Earthsea' } } }
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

          wrap_deferred 'when the scope has multiple criteria' do
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

          wrap_deferred 'when the scope has multiple criteria' do
            it { expect(subject.and(value)).to be == expected }
          end
        end

        wrap_deferred 'with an all scope' do
          it { expect(subject.and(original)).to be == original }

          wrap_deferred 'when the scope has multiple criteria' do
            it { expect(subject.and(original)).to be subject }
          end
        end

        wrap_deferred 'with a none scope' do
          it { expect(subject.and(original)).to be == original }

          wrap_deferred 'when the scope has multiple criteria' do
            it { expect(subject.and(original)).to be == original }
          end
        end

        wrap_deferred 'with an empty conjunction scope' do
          it { expect(subject.and(original)).to be subject }

          wrap_deferred 'when the scope has multiple criteria' do
            it { expect(subject.and(original)).to be subject }
          end
        end

        wrap_deferred 'with an empty criteria scope' do
          it { expect(subject.and(original)).to be subject }

          wrap_deferred 'when the scope has multiple criteria' do
            it { expect(subject.and(original)).to be subject }
          end
        end

        context 'with an empty inverted criteria scope' do
          include_deferred 'with an empty criteria scope'

          let(:inverted) { original.invert }

          it { expect(subject.and(inverted)).to be subject }

          wrap_deferred 'when the scope has multiple criteria' do
            it { expect(subject.and(original)).to be subject }
          end
        end

        wrap_deferred 'with an empty disjunction scope' do
          it { expect(subject.and(original)).to be subject }

          wrap_deferred 'when the scope has multiple criteria' do
            it { expect(subject.and(original)).to be subject }
          end
        end

        wrap_deferred 'with a non-empty conjunction scope' do
          it { expect(subject.and(original)).to be == original }

          wrap_deferred 'when the scope has multiple criteria' do
            let(:expected) do
              Cuprum::Collections::Scopes::ConjunctionScope.new(
                scopes: [subject, *original.scopes]
              )
            end

            it { expect(subject.and(original)).to be == expected }
          end
        end

        wrap_deferred 'with a non-empty criteria scope' do
          let(:expected) do
            Cuprum::Collections::Scopes::CriteriaScope.new(
              criteria: [*subject.criteria, *original.criteria]
            )
          end

          it { expect(subject.and(original)).to be == expected }

          wrap_deferred 'when the scope has multiple criteria' do
            it { expect(subject.and(original)).to be == expected }
          end
        end

        context 'with a non-empty inverted criteria scope' do
          include_deferred 'with a non-empty criteria scope'

          let(:inverted) { original.invert }

          it { expect(subject.and(inverted)).to be == inverted }

          wrap_deferred 'when the scope has multiple criteria' do
            let(:expected) do
              Cuprum::Collections::Scopes::ConjunctionScope.new(
                scopes: [subject, inverted]
              )
            end

            it { expect(subject.and(inverted)).to be == expected }
          end
        end

        wrap_deferred 'with a non-empty disjunction scope' do
          it { expect(subject.and(original)).to be == original }

          wrap_deferred 'when the scope has multiple criteria' do
            let(:expected) do
              Cuprum::Collections::Scopes::ConjunctionScope.new(
                scopes: [subject, original]
              )
            end

            it { expect(subject.and(original)).to be == expected }
          end
        end

        wrap_deferred 'when initialized with inverted: true' do
          describe 'with a block' do
            let(:block) { -> { { 'title' => 'A Wizard of Earthsea' } } }
            let(:expected) do
              Cuprum::Collections::Scope.new(&block)
            end

            it { expect(subject.and(&block)).to be == expected }

            wrap_deferred 'when the scope has multiple criteria' do
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

            wrap_deferred 'when the scope has multiple criteria' do
              let(:expected) do
                wrapped = Cuprum::Collections::Scope.new(value)

                Cuprum::Collections::Scopes::ConjunctionScope.new(
                  scopes: [subject, wrapped]
                )
              end

              it { expect(subject.and(value)).to be == expected }
            end
          end

          wrap_deferred 'with an empty criteria scope' do
            it { expect(subject.and(original)).to be subject }

            wrap_deferred 'when the scope has multiple criteria' do
              it { expect(subject.and(original)).to be subject }
            end
          end

          context 'with an empty inverted criteria scope' do
            include_deferred 'with an empty criteria scope'

            let(:inverted) { original.invert }

            it { expect(subject.and(inverted)).to be subject }

            wrap_deferred 'when the scope has multiple criteria' do
              it { expect(subject.and(inverted)).to be subject }
            end
          end

          wrap_deferred 'with a non-empty criteria scope' do
            it { expect(subject.and(original)).to be == original }

            wrap_deferred 'when the scope has multiple criteria' do
              let(:expected) do
                Cuprum::Collections::Scopes::ConjunctionScope.new(
                  scopes: [subject, original]
                )
              end

              it { expect(subject.and(original)).to be == expected }
            end
          end

          context 'with a non-empty inverted criteria scope' do
            include_deferred 'with a non-empty criteria scope'

            let(:inverted) { original.invert }

            it { expect(subject.and(inverted)).to be == inverted }

            wrap_deferred 'when the scope has multiple criteria' do
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
        include_deferred 'with contexts for composable scopes'

        describe 'with a block' do
          let(:block) { -> { { 'title' => 'A Wizard of Earthsea' } } }
          let(:expected) do
            Cuprum::Collections::Scope.new(&block).invert
          end

          it { expect(subject.not(&block)).to be == expected }

          wrap_deferred 'when the scope has multiple criteria' do
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

          wrap_deferred 'when the scope has multiple criteria' do
            let(:expected) do
              wrapped = Cuprum::Collections::Scope.new(value)

              Cuprum::Collections::Scopes::ConjunctionScope.new(
                scopes: [subject, wrapped.invert]
              )
            end

            it { expect(subject.not(value)).to be == expected }
          end
        end

        wrap_deferred 'with an all scope' do
          it { expect(subject.not(original)).to be == original.invert }

          wrap_deferred 'when the scope has multiple criteria' do
            it { expect(subject.not(original)).to be == original.invert }
          end
        end

        wrap_deferred 'with a none scope' do
          it { expect(subject.not(original)).to be == original.invert }

          wrap_deferred 'when the scope has multiple criteria' do
            it { expect(subject.not(original)).to be subject }
          end
        end

        wrap_deferred 'with an empty conjunction scope' do
          it { expect(subject.not(original)).to be subject }

          wrap_deferred 'when the scope has multiple criteria' do
            it { expect(subject.not(original)).to be subject }
          end
        end

        wrap_deferred 'with an empty criteria scope' do
          it { expect(subject.not(original)).to be subject }

          wrap_deferred 'when the scope has multiple criteria' do
            it { expect(subject.not(original)).to be subject }
          end
        end

        context 'with an empty inverted criteria scope' do
          include_deferred 'with an empty criteria scope'

          let(:inverted) { original.invert }

          it { expect(subject.not(inverted)).to be subject }

          wrap_deferred 'when the scope has multiple criteria' do
            it { expect(subject.not(original)).to be subject }
          end
        end

        wrap_deferred 'with an empty disjunction scope' do
          it { expect(subject.not(original)).to be subject }

          wrap_deferred 'when the scope has multiple criteria' do
            it { expect(subject.not(original)).to be subject }
          end
        end

        wrap_deferred 'with a non-empty conjunction scope' do
          it { expect(subject.not(original)).to be == original.invert }

          wrap_deferred 'when the scope has multiple criteria' do
            let(:expected) do
              Cuprum::Collections::Scopes::ConjunctionScope.new(
                scopes: [subject, original.invert]
              )
            end

            it { expect(subject.not(original)).to be == expected }
          end
        end

        wrap_deferred 'with a non-empty criteria scope' do
          it { expect(subject.not(original)).to be == original.invert }

          wrap_deferred 'when the scope has multiple criteria' do
            let(:expected) do
              Cuprum::Collections::Scopes::ConjunctionScope.new(
                scopes: [subject, original.invert]
              )
            end

            it { expect(subject.not(original)).to be == expected }
          end
        end

        context 'with a non-empty inverted criteria scope' do
          include_deferred 'with a non-empty criteria scope'

          let(:inverted) { original.invert }

          it { expect(subject.not(inverted)).to be == original }

          wrap_deferred 'when the scope has multiple criteria' do
            let(:expected) do
              Cuprum::Collections::Scopes::CriteriaScope.new(
                criteria: [*subject.criteria, *original.criteria]
              )
            end

            it { expect(subject.not(inverted)).to be == expected }
          end
        end

        wrap_deferred 'with a non-empty disjunction scope' do
          it { expect(subject.not(original)).to be == original.invert }

          wrap_deferred 'when the scope has multiple criteria' do
            let(:expected) do
              Cuprum::Collections::Scopes::ConjunctionScope.new(
                scopes: [subject, *original.invert.scopes]
              )
            end

            it { expect(subject.not(original)).to be == expected }
          end
        end

        wrap_deferred 'when initialized with inverted: true' do
          describe 'with a block' do
            let(:block) { -> { { 'title' => 'A Wizard of Earthsea' } } }
            let(:expected) do
              Cuprum::Collections::Scope.new(&block).invert
            end

            it { expect(subject.not(&block)).to be == expected }

            wrap_deferred 'when the scope has multiple criteria' do
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

            wrap_deferred 'when the scope has multiple criteria' do
              let(:expected) do
                wrapped = Cuprum::Collections::Scope.new(value)

                Cuprum::Collections::Scopes::ConjunctionScope.new(
                  scopes: [subject, wrapped.invert]
                )
              end

              it { expect(subject.not(value)).to be == expected }
            end
          end

          wrap_deferred 'with an all scope' do
            it { expect(subject.not(original)).to be == original.invert }

            wrap_deferred 'when the scope has multiple criteria' do
              it { expect(subject.not(original)).to be == original.invert }
            end
          end

          wrap_deferred 'with a none scope' do
            it { expect(subject.not(original)).to be == original.invert }

            wrap_deferred 'when the scope has multiple criteria' do
              it { expect(subject.not(original)).to be subject }
            end
          end

          wrap_deferred 'with an empty conjunction scope' do
            it { expect(subject.not(original)).to be subject }

            wrap_deferred 'when the scope has multiple criteria' do
              it { expect(subject.not(original)).to be subject }
            end
          end

          wrap_deferred 'with an empty criteria scope' do
            it { expect(subject.not(original)).to be subject }

            wrap_deferred 'when the scope has multiple criteria' do
              it { expect(subject.not(original)).to be subject }
            end
          end

          context 'with an empty inverted criteria scope' do
            include_deferred 'with an empty criteria scope'

            let(:inverted) { original.invert }

            it { expect(subject.not(inverted)).to be subject }

            wrap_deferred 'when the scope has multiple criteria' do
              it { expect(subject.not(original)).to be subject }
            end
          end

          wrap_deferred 'with an empty disjunction scope' do
            it { expect(subject.not(original)).to be subject }

            wrap_deferred 'when the scope has multiple criteria' do
              it { expect(subject.not(original)).to be subject }
            end
          end

          wrap_deferred 'with a non-empty conjunction scope' do
            it { expect(subject.not(original)).to be == original.invert }

            wrap_deferred 'when the scope has multiple criteria' do
              let(:expected) do
                Cuprum::Collections::Scopes::ConjunctionScope.new(
                  scopes: [subject, original.invert]
                )
              end

              it { expect(subject.not(original)).to be == expected }
            end
          end

          wrap_deferred 'with a non-empty criteria scope' do
            it { expect(subject.not(original)).to be == original.invert }

            wrap_deferred 'when the scope has multiple criteria' do
              let(:expected) do
                Cuprum::Collections::Scopes::ConjunctionScope.new(
                  scopes: [subject, original.invert]
                )
              end

              it { expect(subject.not(original)).to be == expected }
            end
          end

          context 'with a non-empty inverted criteria scope' do
            include_deferred 'with a non-empty criteria scope'

            let(:inverted) { original.invert }

            it { expect(subject.not(inverted)).to be == original }

            wrap_deferred 'when the scope has multiple criteria' do
              let(:expected) do
                Cuprum::Collections::Scopes::ConjunctionScope.new(
                  scopes: [subject, original]
                )
              end

              it { expect(subject.not(inverted)).to be == expected }
            end
          end

          wrap_deferred 'with a non-empty disjunction scope' do
            it { expect(subject.not(original)).to be == original.invert }

            wrap_deferred 'when the scope has multiple criteria' do
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
        include_deferred 'with contexts for composable scopes'

        describe 'with a block' do
          let(:block) { -> { { 'title' => 'A Wizard of Earthsea' } } }
          let(:expected) do
            Cuprum::Collections::Scope.new(&block)
          end

          it { expect(subject.or(&block)).to be == expected }

          wrap_deferred 'when the scope has multiple criteria' do
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

          wrap_deferred 'when the scope has multiple criteria' do
            let(:expected) do
              Cuprum::Collections::Scopes::DisjunctionScope.new(
                scopes: [subject, super()]
              )
            end

            it { expect(subject.or(value)).to be == expected }
          end
        end

        wrap_deferred 'with an all scope' do
          it { expect(subject.or(original)).to be == original }

          wrap_deferred 'when the scope has multiple criteria' do
            it { expect(subject.or(original)).to be == original }
          end
        end

        wrap_deferred 'with a none scope' do
          it { expect(subject.or(original)).to be subject }

          wrap_deferred 'when the scope has multiple criteria' do
            it { expect(subject.or(original)).to be subject }
          end
        end

        wrap_deferred 'with an empty conjunction scope' do
          it { expect(subject.or(original)).to be subject }

          wrap_deferred 'when the scope has multiple criteria' do
            it { expect(subject.or(original)).to be subject }
          end
        end

        wrap_deferred 'with an empty criteria scope' do
          it { expect(subject.or(original)).to be subject }

          wrap_deferred 'when the scope has multiple criteria' do
            it { expect(subject.or(original)).to be subject }
          end
        end

        wrap_deferred 'with an empty disjunction scope' do
          it { expect(subject.or(original)).to be subject }

          wrap_deferred 'when the scope has multiple criteria' do
            it { expect(subject.or(original)).to be subject }
          end
        end

        wrap_deferred 'with a non-empty conjunction scope' do
          it { expect(subject.or(original)).to be == original }

          wrap_deferred 'when the scope has multiple criteria' do
            let(:expected) do
              Cuprum::Collections::Scopes::DisjunctionScope.new(
                scopes: [subject, original]
              )
            end

            it { expect(subject.or(original)).to be == expected }
          end
        end

        wrap_deferred 'with a non-empty criteria scope' do
          it { expect(subject.or(original)).to be == original }

          wrap_deferred 'when the scope has multiple criteria' do
            let(:expected) do
              Cuprum::Collections::Scopes::DisjunctionScope.new(
                scopes: [subject, original]
              )
            end

            it { expect(subject.or(original)).to be == expected }
          end
        end

        wrap_deferred 'with a non-empty disjunction scope' do
          it { expect(subject.or(original)).to be == original }

          wrap_deferred 'when the scope has multiple criteria' do
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

    # @option deferred_options ignore_invalid [Boolean] if true, skips tests for
    #   handling invalid operators. Defaults to false.
    # @option deferred_options inverted [Boolean] if true, filters data that
    #   does not match the criteria. Defaults to false.
    deferred_examples 'should filter data by criteria' do |**deferred_options|
      deferred_context 'with data' do
        let(:data) do
          Cuprum::Collections::RSpec::Fixtures::BOOKS_FIXTURES
        end
      end

      let(:matching) { data }
      let(:expected) do
        deferred_options.fetch(:inverted, false) ? data - matching : matching
      end

      context 'when the scope has no criteria' do
        describe 'with empty data' do
          let(:data) { [] }

          it { expect(filtered_data).to be == [] }
        end

        wrap_deferred 'with data' do
          let(:matching) { data }

          it { expect(filtered_data).to match_array expected }
        end
      end

      context 'when the scope has an equality criterion' do
        let(:criteria) do
          described_class.parse({ 'title' => 'The Word for World is Forest' })
        end

        describe 'with empty data' do
          let(:data) { [] }

          it { expect(filtered_data).to be == [] }
        end

        wrap_deferred 'with data' do
          let(:matching) do
            data.select do |item|
              item['title'] == 'The Word for World is Forest'
            end
          end

          it { expect(filtered_data).to match_array expected }
        end
      end

      context 'when the scope has a greater than criterion' do
        let(:criteria) do
          described_class.parse do |scope|
            { 'published_at' => scope.greater_than('1972-03-13') }
          end
        end

        describe 'with empty data' do
          let(:data) { [] }

          it { expect(filtered_data).to be == [] }
        end

        wrap_deferred 'with data' do
          let(:matching) do
            data.select do |item|
              item['published_at'] > '1972-03-13'
            end
          end

          it { expect(filtered_data).to match_array expected }
        end
      end

      context 'when the scope has a greater than or equal to criterion' do
        let(:criteria) do
          described_class.parse do |scope|
            { 'published_at' => scope.greater_than_or_equal_to('1972-03-13') }
          end
        end

        describe 'with empty data' do
          let(:data) { [] }

          it { expect(filtered_data).to be == [] }
        end

        wrap_deferred 'with data' do
          let(:matching) do
            data.select do |item|
              item['published_at'] >= '1972-03-13'
            end
          end

          it { expect(filtered_data).to match_array expected }
        end
      end

      context 'when the scope has a less than criterion' do
        let(:criteria) do
          described_class.parse do |scope|
            { 'published_at' => scope.less_than('1972-03-13') }
          end
        end

        describe 'with empty data' do
          let(:data) { [] }

          it { expect(filtered_data).to be == [] }
        end

        wrap_deferred 'with data' do
          let(:matching) do
            data.select do |item|
              item['published_at'] < '1972-03-13'
            end
          end

          it { expect(filtered_data).to match_array expected }
        end
      end

      context 'when the scope has a less than or equal to criterion' do
        let(:criteria) do
          described_class.parse do |scope|
            { 'published_at' => scope.less_than_or_equal_to('1972-03-13') }
          end
        end

        describe 'with empty data' do
          let(:data) { [] }

          it { expect(filtered_data).to be == [] }
        end

        wrap_deferred 'with data' do
          let(:matching) do
            data.select do |item|
              item['published_at'] <= '1972-03-13'
            end
          end

          it { expect(filtered_data).to match_array expected }
        end
      end

      context 'when the scope has a not equal criterion' do
        let(:criteria) do
          described_class.parse do |scope|
            { 'author' => scope.not_equal('J.R.R. Tolkien') }
          end
        end

        describe 'with empty data' do
          let(:data) { [] }

          it { expect(filtered_data).to be == [] }
        end

        wrap_deferred 'with data' do
          let(:matching) do
            data.reject do |item|
              item['author'] == 'J.R.R. Tolkien'
            end
          end

          it { expect(filtered_data).to match_array expected }
        end
      end

      context 'when the scope has a not null criterion' do
        let(:criteria) do
          described_class.parse do |scope|
            { 'series' => scope.not_null }
          end
        end

        describe 'with empty data' do
          let(:data) { [] }

          it { expect(filtered_data).to be == [] }
        end

        wrap_deferred 'with data' do
          let(:matching) do
            data.reject do |item|
              item['series'].nil?
            end
          end

          it { expect(filtered_data).to match_array expected }
        end
      end

      context 'when the scope has a not one of criterion' do
        let(:criteria) do
          described_class.parse do |scope|
            titles = ['The Fellowship Of The Ring', 'The Two Towers']

            { 'title' => scope.not_one_of(titles) }
          end
        end

        describe 'with empty data' do
          let(:data) { [] }

          it { expect(filtered_data).to be == [] }
        end

        wrap_deferred 'with data' do
          let(:matching) do
            data.reject do |item|
              ['The Fellowship Of The Ring', 'The Two Towers']
                .include?(item['title'])
            end
          end

          it { expect(filtered_data).to match_array expected }
        end
      end

      context 'when the scope has a null criterion' do
        let(:criteria) do
          described_class.parse do |scope|
            { 'series' => scope.null }
          end
        end

        describe 'with empty data' do
          let(:data) { [] }

          it { expect(filtered_data).to be == [] }
        end

        wrap_deferred 'with data' do
          let(:matching) do
            data.select do |item|
              item['series'].nil?
            end
          end

          it { expect(filtered_data).to match_array expected }
        end
      end

      context 'when the scope has a one of criterion' do
        let(:criteria) do
          described_class.parse do |scope|
            titles = ['The Fellowship Of The Ring', 'The Two Towers']

            { 'title' => scope.one_of(titles) }
          end
        end

        describe 'with empty data' do
          let(:data) { [] }

          it { expect(filtered_data).to be == [] }
        end

        wrap_deferred 'with data' do
          let(:matching) do
            data.select do |item|
              ['The Fellowship Of The Ring', 'The Two Towers']
                .include?(item['title'])
            end
          end

          it { expect(filtered_data).to match_array expected }
        end
      end

      context 'when the scope has mixed criteria' do
        let(:criteria) do
          described_class.parse do |scope|
            titles = ['The Fellowship Of The Ring', 'The Two Towers']

            {
              'author' => 'J.R.R. Tolkien',
              'title'  => scope.not_one_of(titles)
            }
          end
        end

        describe 'with empty data' do
          let(:data) { [] }

          it { expect(filtered_data).to be == [] }
        end

        wrap_deferred 'with data' do
          let(:matching) do
            data
              .select { |item| item['author'] == 'J.R.R. Tolkien' }
              .reject do |item|
                ['The Fellowship Of The Ring', 'The Two Towers']
                  .include?(item['title'])
              end
          end

          it { expect(filtered_data).to match_array expected }
        end
      end

      context 'when the scope has multiple matching criteria' do
        let(:criteria) do
          described_class.parse({
            'author' => 'J.R.R. Tolkien',
            'series' => 'The Lord of the Rings'
          })
        end

        describe 'with empty data' do
          let(:data) { [] }

          it { expect(filtered_data).to be == [] }
        end

        wrap_deferred 'with data' do
          let(:matching) do
            data
              .select { |item| item['author'] == 'J.R.R. Tolkien' }
              .select { |item| item['series'] == 'The Lord of the Rings' }
          end

          it { expect(filtered_data).to match_array expected }
        end
      end

      context 'when the scope has non-overlapping criteria' do
        let(:criteria) do
          described_class.parse({
            'author' => 'J.R.R. Tolkien',
            'series' => 'Earthsea'
          })
        end

        describe 'with empty data' do
          let(:data) { [] }

          it { expect(filtered_data).to be == [] }
        end

        wrap_deferred 'with data' do
          let(:matching) do
            data
              .select { |item| item['author'] == 'J.R.R. Tolkien' }
              .select { |item| item['series'] == 'Earthsea' }
          end

          it { expect(filtered_data).to match_array expected }
        end
      end

      context 'when the scope has invalid operators' do
        next if deferred_options.fetch(:ignore_invalid, false)

        let(:criteria) { [['title', :random, nil]] }
        let(:error_class) do
          Cuprum::Collections::Queries::UnknownOperatorException
        end
        let(:error_message) do
          'unknown operator "random"'
        end

        describe 'with empty data' do
          let(:data) { [] }

          it 'should return an empty result or raise an exception',
            :aggregate_failures \
          do
            # :nocov:
            begin
              actual = filtered_data
            rescue StandardError => exception
              expect(exception).to be_a error_class
              expect(exception.message).to be == error_message

              next
            end

            expect(actual).to be == []
            # :nocov:
          end
        end

        wrap_deferred 'with data' do
          it 'should raise an exception' do
            expect { filtered_data }
              .to raise_error error_class, error_message
          end
        end
      end
    end
  end
end
