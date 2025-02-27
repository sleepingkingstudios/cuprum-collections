# frozen_string_literal: true

require 'cuprum/collections/rspec/contracts/scopes'
require 'cuprum/collections/rspec/contracts/scope_contracts'
require 'cuprum/collections/rspec/contracts/scopes/composition_contracts'

module Cuprum::Collections::RSpec::Contracts::Scopes
  # Contracts for asserting on criteria scope objects.
  module CriteriaContracts
    include Cuprum::Collections::RSpec::Contracts::ScopeContracts
    include Cuprum::Collections::RSpec::Contracts::Scopes::CompositionContracts

    # Contract validating the behavior of a Criteria scope implementation.
    module ShouldBeACriteriaScopeContract
      extend RSpec::SleepingKingStudios::Contract

      # @!method apply(example_group, abstract: false, constructor: true, equality: true, ignore_uninvertible: false)
      #   Adds the contract to the example group.
      #
      #   @param example_group [RSpec::Core::ExampleGroup] the example group to
      #     which the contract is applied.
      #   @param abstract [Boolean] if true, the scope is abstract and does not
      #     define a #call implementation. Defaults to false.
      #   @param equality [Boolean] if false, skips the specs for the equality
      #     operator #==. Defaults to true.
      #   @param ignore_uninvertible [Boolean] if true, skips the specs for
      #     uninvertible operators. Defaults to false.
      contract do |
        abstract:            false,
        equality:            true,
        constructor:         true,
        ignore_uninvertible: false
      |
        shared_context 'when initialized with inverted: true' do
          let(:constructor_options) { super().merge(inverted: true) }
        end

        shared_context 'with criteria' do
          let(:criteria) do
            operators = Cuprum::Collections::Queries::Operators

            [
              ['title',  operators::EQUAL, 'Gideon the Ninth'],
              ['author', operators::EQUAL, 'Tamsyn Muir']
            ]
          end
        end

        let(:criteria) { [] }

        describe '.new' do
          next unless constructor

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

          def parse_criteria(*args, &block)
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

          include_contract 'should parse criteria'
        end

        describe '.parse' do
          def parse_criteria(*args, &block)
            return described_class.parse(&block) if args.empty?

            described_class.parse(args.first, &block)
          end

          it 'should define class method' do
            expect(described_class)
              .to respond_to(:parse)
              .with(0..1).arguments
              .and_a_block
          end

          include_contract 'should parse criteria'
        end

        include_contract 'should be a scope', invertible: true

        include_contract 'should compose scopes for criteria'

        describe '#==' do
          next unless equality

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

            wrap_context 'with criteria' do
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

            wrap_context 'when initialized with inverted: true' do
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

              wrap_context 'with criteria' do
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

            wrap_context 'with criteria' do
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

            wrap_context 'when initialized with inverted: true' do
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

              wrap_context 'with criteria' do
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

          wrap_context 'when initialized with inverted: true' do
            it { expect(subject.as_json).to be == expected }
          end

          wrap_context 'with criteria' do
            it { expect(subject.as_json).to be == expected }

            wrap_context 'when initialized with inverted: true' do
              it { expect(subject.as_json).to be == expected }
            end
          end
        end

        describe '#call' do
          next if abstract

          it { expect(subject).to respond_to(:call) }

          include_contract 'should filter data by criteria'

          context 'when the scope is inverted' do
            subject { super().invert }

            let(:matching_data) { data - filtered_data }

            include_contract 'should filter data by criteria',
              ignore_invalid: true,
              inverted:       true
          end
        end

        describe '#criteria' do
          include_examples 'should define reader', :criteria, -> { criteria }

          wrap_context 'with criteria' do
            it { expect(subject.criteria).to be == criteria }
          end
        end

        describe '#empty?' do
          include_examples 'should define predicate', :empty?, true

          wrap_context 'with criteria' do
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
              next if ignore_uninvertible

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

          wrap_context 'when initialized with inverted: true' do
            it { expect(copy).to be_a described_class }

            it { expect(copy.inverted?).to be false }

            include_examples 'should invert the criteria'
          end
        end

        describe '#inverted?' do
          include_examples 'should define predicate', :inverted?, false

          wrap_context 'when initialized with inverted: true' do
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

          wrap_context 'with criteria' do
            it "should not change the original scope's criteria" do
              expect { subject.with_criteria(new_criteria) }
                .not_to change(subject, :criteria)
            end

            it "should set the copied scope's criteria" do
              expect(subject.with_criteria(new_criteria).criteria)
                .to be == new_criteria
            end
          end

          wrap_context 'when initialized with inverted: true' do
            it 'should return an inverted scope' do
              expect(subject.with_criteria(new_criteria).inverted?).to be true
            end
          end
        end
      end
    end

    # Contract validating the scope filters data based on the criteria.
    module ShouldFilterDataByCriteriaContract
      extend RSpec::SleepingKingStudios::Contract

      # @!method apply(example_group, **options)
      #   Adds the contract to the example group.
      #
      #   @param example_group [RSpec::Core::ExampleGroup] the example group to
      #     which the contract is applied.
      #   @param options [Hash] additional options for the contract.
      #
      #   @option options ignore_invalid [Boolean] if true, skips tests for
      #     handling invalid operators. Defaults to false.
      #   @option options inverted [Boolean] if true, filters data that does not
      #     match the criteria. Defaults to false.
      contract do |ignore_invalid: false, inverted: false|
        shared_context 'with data' do
          let(:data) do
            Cuprum::Collections::RSpec::Fixtures::BOOKS_FIXTURES
          end
        end

        let(:matching) { data }
        let(:expected) { inverted ? data - matching : matching }

        context 'when the scope has no criteria' do
          describe 'with empty data' do
            let(:data) { [] }

            it { expect(filtered_data).to be == [] }
          end

          wrap_context 'with data' do
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

          wrap_context 'with data' do
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

          wrap_context 'with data' do
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

          wrap_context 'with data' do
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

          wrap_context 'with data' do
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

          wrap_context 'with data' do
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

          wrap_context 'with data' do
            let(:matching) do
              data.reject do |item|
                item['author'] == 'J.R.R. Tolkien'
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

          wrap_context 'with data' do
            let(:matching) do
              data.reject do |item|
                ['The Fellowship Of The Ring', 'The Two Towers']
                  .include?(item['title'])
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

          wrap_context 'with data' do
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

          wrap_context 'with data' do
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

          wrap_context 'with data' do
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

          wrap_context 'with data' do
            let(:matching) do
              data
                .select { |item| item['author'] == 'J.R.R. Tolkien' }
                .select { |item| item['series'] == 'Earthsea' }
            end

            it { expect(filtered_data).to match_array expected }
          end
        end

        context 'when the scope has invalid operators' do
          next if ignore_invalid

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

          wrap_context 'with data' do
            it 'should raise an exception' do
              expect { filtered_data }
                .to raise_error error_class, error_message
            end
          end
        end
      end
    end

    # Contract validating the parsing of criteria.
    module ShouldParseCriteriaContract
      extend RSpec::SleepingKingStudios::Contract

      # @!method apply(example_group)
      #   Adds the contract to the example group.
      #
      #   @param example_group [RSpec::Core::ExampleGroup] the example group to
      #     which the contract is applied.
      contract do
        describe 'with a block' do
          include_contract 'should parse criteria from a block'
        end

        describe 'with a hash' do
          include_contract 'should parse criteria from a hash'
        end

        describe 'with a hash and a block' do
          let(:operators) { Cuprum::Collections::Queries::Operators }
          let(:block) do
            lambda do |scope|
              { 'author' => scope.one_of('J.R.R. Tolkien', 'Ursula K. LeGuin') }
            end
          end
          let(:value) do
            { 'category' => 'Science Fiction and Fantasy' }
          end
          let(:expected) do
            [
              [
                'category',
                operators::EQUAL,
                'Science Fiction and Fantasy'
              ],
              [
                'author',
                operators::ONE_OF,
                ['J.R.R. Tolkien', 'Ursula K. LeGuin']
              ]
            ]
          end

          it 'should parse the criteria' do
            expect(parse_criteria(value, &block)).to be == expected
          end
        end
      end
    end

    # Contract validating the parsing of criteria from a Hash.
    module ShouldParseCriteriaFromABlockContract
      extend RSpec::SleepingKingStudios::Contract

      # @!method apply(example_group)
      #   Adds the contract to the example group.
      #
      #   @param example_group [RSpec::Core::ExampleGroup] the example group to
      #     which the contract is applied.
      contract do
        let(:operators) { Cuprum::Collections::Queries::Operators }

        describe 'without a block' do
          let(:error_message) { 'no block given' }

          it 'should raise an exception' do
            expect { parse_criteria }
              .to raise_error ArgumentError, error_message
          end
        end

        describe 'with a block returning nil' do
          let(:error_message) do
            'value must be a Hash with String or Symbol keys'
          end

          it 'should raise an exception' do
            expect { parse_criteria { nil } }
              .to raise_error ArgumentError, error_message
          end
        end

        describe 'with a block returning an Object' do
          let(:error_message) do
            'value must be a Hash with String or Symbol keys'
          end

          it 'should raise an exception' do
            expect { parse_criteria { Object.new.freeze } }
              .to raise_error ArgumentError, error_message
          end
        end

        describe 'with a block returning a Hash with invalid keys' do
          let(:error_message) do
            'value must be a Hash with String or Symbol keys'
          end
          let(:block)         { -> { { nil => 'invalid' } } }

          it 'should raise an exception' do
            expect { parse_criteria(&block) }
              .to raise_error ArgumentError, error_message
          end
        end

        describe 'with a block returning an empty Hash' do
          let(:block) { -> { {} } }

          it { expect(parse_criteria(&block)).to be == [] }
        end

        describe 'with a block returning a Hash with one key' do
          let(:operators) { Cuprum::Collections::Queries::Operators }
          let(:block) do
            -> { { 'title' => 'A Wizard of Earthsea' } }
          end
          let(:expected) do
            [['title', operators::EQUAL, 'A Wizard of Earthsea']]
          end

          it { expect(parse_criteria(&block)).to be == expected }
        end

        describe 'with a Hash with many String keys' do
          let(:operators) { Cuprum::Collections::Queries::Operators }
          let(:block) do
            lambda do
              {
                'title'  => 'A Wizard of Earthsea',
                'author' => 'Ursula K. LeGuin',
                'series' => 'Earthsea'
              }
            end
          end
          let(:expected) do
            [
              ['title', operators::EQUAL, 'A Wizard of Earthsea'],
              ['author', operators::EQUAL, 'Ursula K. LeGuin'],
              ['series', operators::EQUAL, 'Earthsea']
            ]
          end

          it { expect(parse_criteria(&block)).to be == expected }
        end

        describe 'with a Hash with many Symbol keys' do
          let(:operators) { Cuprum::Collections::Queries::Operators }
          let(:block) do
            lambda do
              {
                title:  'A Wizard of Earthsea',
                author: 'Ursula K. LeGuin',
                series: 'Earthsea'
              }
            end
          end
          let(:expected) do
            [
              ['title', operators::EQUAL, 'A Wizard of Earthsea'],
              ['author', operators::EQUAL, 'Ursula K. LeGuin'],
              ['series', operators::EQUAL, 'Earthsea']
            ]
          end

          it { expect(parse_criteria(&block)).to be == expected }
        end

        describe 'with a Hash with an "eq" operator' do
          let(:block) do
            ->(scope) { { 'title' => scope.eq('A Wizard of Earthsea') } }
          end
          let(:expected) do
            [['title', operators::EQUAL, 'A Wizard of Earthsea']]
          end

          it 'should parse the criteria' do
            expect(parse_criteria(&block)).to be == expected
          end
        end

        describe 'with a Hash with an "equal" operator' do
          let(:block) do
            ->(scope) { { 'title' => scope.equal('A Wizard of Earthsea') } }
          end
          let(:expected) do
            [['title', operators::EQUAL, 'A Wizard of Earthsea']]
          end

          it 'should parse the criteria' do
            expect(parse_criteria(&block)).to be == expected
          end
        end

        describe 'with a Hash with an "equals" operator' do
          let(:block) do
            ->(scope) { { 'title' => scope.equals('A Wizard of Earthsea') } }
          end
          let(:expected) do
            [['title', operators::EQUAL, 'A Wizard of Earthsea']]
          end

          it 'should parse the criteria' do
            expect(parse_criteria(&block)).to be == expected
          end
        end

        describe 'with a Hash with a "greater_than" operator' do
          let(:block) do
            ->(scope) { { 'published_at' => scope.greater_than('1970-01-01') } }
          end
          let(:expected) do
            [['published_at', operators::GREATER_THAN, '1970-01-01']]
          end

          it 'should parse the criteria' do
            expect(parse_criteria(&block)).to be == expected
          end
        end

        describe 'with a Hash with a "greater_than_or_equal_to" operator' do
          let(:block) do
            lambda do |scope|
              { 'published_at' => scope.greater_than_or_equal_to('1970-01-01') }
            end
          end
          let(:expected) do
            [
              [
                'published_at',
                operators::GREATER_THAN_OR_EQUAL_TO,
                '1970-01-01'
              ]
            ]
          end

          it 'should parse the criteria' do
            expect(parse_criteria(&block)).to be == expected
          end
        end

        describe 'with a Hash with a "gt" operator' do
          let(:block) do
            ->(scope) { { 'published_at' => scope.gt('1970-01-01') } }
          end
          let(:expected) do
            [['published_at', operators::GREATER_THAN, '1970-01-01']]
          end

          it 'should parse the criteria' do
            expect(parse_criteria(&block)).to be == expected
          end
        end

        describe 'with a Hash with a "gte" operator' do
          let(:block) do
            ->(scope) { { 'published_at' => scope.gte('1970-01-01') } }
          end
          let(:expected) do
            [
              [
                'published_at',
                operators::GREATER_THAN_OR_EQUAL_TO,
                '1970-01-01'
              ]
            ]
          end

          it 'should parse the criteria' do
            expect(parse_criteria(&block)).to be == expected
          end
        end

        describe 'with a Hash with a "less_than" operator' do
          let(:block) do
            ->(scope) { { 'published_at' => scope.less_than('1970-01-01') } }
          end
          let(:expected) do
            [['published_at', operators::LESS_THAN, '1970-01-01']]
          end

          it 'should parse the criteria' do
            expect(parse_criteria(&block)).to be == expected
          end
        end

        describe 'with a Hash with a "less_than_or_equal_to" operator' do
          let(:block) do
            lambda do |scope|
              { 'published_at' => scope.less_than_or_equal_to('1970-01-01') }
            end
          end
          let(:expected) do
            [['published_at', operators::LESS_THAN_OR_EQUAL_TO, '1970-01-01']]
          end

          it 'should parse the criteria' do
            expect(parse_criteria(&block)).to be == expected
          end
        end

        describe 'with a Hash with a "lt" operator' do
          let(:block) do
            ->(scope) { { 'published_at' => scope.lt('1970-01-01') } }
          end
          let(:expected) do
            [['published_at', operators::LESS_THAN, '1970-01-01']]
          end

          it 'should parse the criteria' do
            expect(parse_criteria(&block)).to be == expected
          end
        end

        describe 'with a Hash with a "lte" operator' do
          let(:block) do
            ->(scope) { { 'published_at' => scope.lte('1970-01-01') } }
          end
          let(:expected) do
            [['published_at', operators::LESS_THAN_OR_EQUAL_TO, '1970-01-01']]
          end

          it 'should parse the criteria' do
            expect(parse_criteria(&block)).to be == expected
          end
        end

        describe 'with a Hash with a "ne" operator' do
          let(:block) do
            ->(scope) { { 'series' => scope.ne('Earthsea') } }
          end
          let(:expected) do
            [['series', operators::NOT_EQUAL, 'Earthsea']]
          end

          it 'should parse the criteria' do
            expect(parse_criteria(&block)).to be == expected
          end
        end

        describe 'with a Hash with a "not_equal" operator' do
          let(:block) do
            ->(scope) { { 'series' => scope.not_equal('Earthsea') } }
          end
          let(:expected) do
            [['series', operators::NOT_EQUAL, 'Earthsea']]
          end

          it 'should parse the criteria' do
            expect(parse_criteria(&block)).to be == expected
          end
        end

        describe 'with a Hash with a "not_one_of" operator and an Array' do
          let(:block) do
            lambda do |scope|
              {
                'series' => scope.not_one_of(
                  ['Earthsea', 'The Lord of the Rings']
                )
              }
            end
          end
          let(:expected) do
            [
              [
                'series',
                operators::NOT_ONE_OF,
                ['Earthsea', 'The Lord of the Rings']
              ]
            ]
          end

          it 'should parse the criteria' do
            expect(parse_criteria(&block)).to be == expected
          end
        end

        describe 'with a Hash with a "not_one_of" operator and values' do
          let(:block) do
            lambda do |scope|
              {
                'series' => scope.not_one_of(
                  'Earthsea',
                  'The Lord of the Rings'
                )
              }
            end
          end
          let(:expected) do
            [
              [
                'series',
                operators::NOT_ONE_OF,
                ['Earthsea', 'The Lord of the Rings']
              ]
            ]
          end

          it 'should parse the criteria' do
            expect(parse_criteria(&block)).to be == expected
          end
        end

        describe 'with a Hash with a "one_of" operator and an Array' do
          let(:block) do
            lambda do |scope|
              {
                'series' => scope.one_of(
                  ['Earthsea', 'The Lord of the Rings']
                )
              }
            end
          end
          let(:expected) do
            [
              [
                'series',
                operators::ONE_OF,
                ['Earthsea', 'The Lord of the Rings']
              ]
            ]
          end

          it 'should parse the criteria' do
            expect(parse_criteria(&block)).to be == expected
          end
        end

        describe 'with a Hash with a "one_of" operator and values' do
          let(:block) do
            lambda do |scope|
              {
                'series' => scope.one_of(
                  'Earthsea',
                  'The Lord of the Rings'
                )
              }
            end
          end
          let(:expected) do
            [
              [
                'series',
                operators::ONE_OF,
                ['Earthsea', 'The Lord of the Rings']
              ]
            ]
          end

          it 'should parse the criteria' do
            expect(parse_criteria(&block)).to be == expected
          end
        end

        describe 'with a Hash with an unknown operator' do
          let(:error_class) do
            Cuprum::Collections::Queries::UnknownOperatorException
          end
          let(:error_message) do
            'unknown operator "random"'
          end
          let(:block) do
            -> { { 'genre' => random('Science Fiction', 'Fantasy') } }
          end

          it 'should raise an exception' do
            expect { parse_criteria(&block) }
              .to raise_error error_class, error_message
          end

          it 'should preserve the original exception', :aggregate_failures do
            parse_criteria(&block)
          rescue error_class => exception
            expect(exception.cause).to be_a NameError
            expect(exception.name).to be == :random
          end
        end

        describe 'with a Hash with multiple operators' do
          let(:block) do
            lambda do |scope|
              {
                'published_at' => scope.greater_than('1970-01-01'),
                'series'       => scope.one_of(
                  ['Earthsea', 'The Lord of the Rings']
                ),
                'title'        => scope.not_equal('The Tombs of Atuan')
              }
            end
          end
          let(:expected) do
            [
              [
                'published_at',
                operators::GREATER_THAN,
                '1970-01-01'
              ],
              [
                'series',
                operators::ONE_OF,
                ['Earthsea', 'The Lord of the Rings']
              ],
              [
                'title',
                operators::NOT_EQUAL,
                'The Tombs of Atuan'
              ]
            ]
          end

          it 'should parse the criteria' do
            expect(parse_criteria(&block)).to be == expected
          end
        end

        describe 'with a Hash with mixed keys and operators' do
          let(:block) do
            lambda do |scope|
              {
                'author'   => scope.one_of(
                  'J.R.R. Tolkien',
                  'Ursula K. LeGuin'
                ),
                'category' => 'Science Fiction and Fantasy'
              }
            end
          end
          let(:expected) do
            [
              [
                'author',
                operators::ONE_OF,
                ['J.R.R. Tolkien', 'Ursula K. LeGuin']
              ],
              [
                'category',
                operators::EQUAL,
                'Science Fiction and Fantasy'
              ]
            ]
          end

          it 'should parse the criteria' do
            expect(parse_criteria(&block)).to be == expected
          end
        end

        # @deprecated v0.5.0 Implicit receivers are deprecated.
        describe 'with a block with legacy implicit receiver' do
          shared_examples 'should print a deprecation warning for' \
          do |operator_name|
            let(:deprecation_warning) do
              '#parse with implicit receiver'
            end
            let(:deprecation_message) do
              'Pass a block with one parameter to #parse: { |scope| { scope' \
                ".#{operator_name}: value } }"
            end

            it 'should print a deprecation warning' do
              parse_criteria(&block)

              expect(tools.core_tools)
                .to have_received(:deprecate)
                .with(deprecation_warning, message: deprecation_message)
            end
          end

          def tools
            SleepingKingStudios::Tools::Toolbelt.instance
          end

          before(:example) do
            allow(tools.core_tools).to receive(:deprecate)
          end

          describe 'with a Hash with an "eq" operator' do
            let(:block) do
              -> { { 'title' => eq('A Wizard of Earthsea') } }
            end
            let(:expected) do
              [['title', operators::EQUAL, 'A Wizard of Earthsea']]
            end

            it 'should parse the criteria' do
              expect(parse_criteria(&block)).to be == expected
            end

            include_examples 'should print a deprecation warning for', 'eq'
          end

          describe 'with a Hash with an "equal" operator' do
            let(:block) do
              -> { { 'title' => equal('A Wizard of Earthsea') } }
            end
            let(:expected) do
              [['title', operators::EQUAL, 'A Wizard of Earthsea']]
            end

            it 'should parse the criteria' do
              expect(parse_criteria(&block)).to be == expected
            end

            include_examples 'should print a deprecation warning for', 'equal'
          end

          describe 'with a Hash with an "equals" operator' do
            let(:block) do
              -> { { 'title' => equals('A Wizard of Earthsea') } }
            end
            let(:expected) do
              [['title', operators::EQUAL, 'A Wizard of Earthsea']]
            end

            it 'should parse the criteria' do
              expect(parse_criteria(&block)).to be == expected
            end

            include_examples 'should print a deprecation warning for', 'equals'
          end

          describe 'with a Hash with a "greater_than" operator' do
            let(:block) do
              -> { { 'published_at' => greater_than('1970-01-01') } }
            end
            let(:expected) do
              [['published_at', operators::GREATER_THAN, '1970-01-01']]
            end

            it 'should parse the criteria' do
              expect(parse_criteria(&block)).to be == expected
            end

            include_examples 'should print a deprecation warning for',
              'greater_than'
          end

          describe 'with a Hash with a "greater_than_or_equal_to" operator' do
            let(:block) do
              lambda do
                { 'published_at' => greater_than_or_equal_to('1970-01-01') }
              end
            end
            let(:expected) do
              [
                [
                  'published_at',
                  operators::GREATER_THAN_OR_EQUAL_TO,
                  '1970-01-01'
                ]
              ]
            end

            it 'should parse the criteria' do
              expect(parse_criteria(&block)).to be == expected
            end

            include_examples 'should print a deprecation warning for',
              'greater_than_or_equal_to'
          end

          describe 'with a Hash with a "gt" operator' do
            let(:block) do
              -> { { 'published_at' => gt('1970-01-01') } }
            end
            let(:expected) do
              [['published_at', operators::GREATER_THAN, '1970-01-01']]
            end

            it 'should parse the criteria' do
              expect(parse_criteria(&block)).to be == expected
            end

            include_examples 'should print a deprecation warning for', 'gt'
          end

          describe 'with a Hash with a "gte" operator' do
            let(:block) do
              -> { { 'published_at' => gte('1970-01-01') } }
            end
            let(:expected) do
              [
                [
                  'published_at',
                  operators::GREATER_THAN_OR_EQUAL_TO,
                  '1970-01-01'
                ]
              ]
            end

            it 'should parse the criteria' do
              expect(parse_criteria(&block)).to be == expected
            end

            include_examples 'should print a deprecation warning for', 'gte'
          end

          describe 'with a Hash with a "less_than" operator' do
            let(:block) do
              -> { { 'published_at' => less_than('1970-01-01') } }
            end
            let(:expected) do
              [['published_at', operators::LESS_THAN, '1970-01-01']]
            end

            it 'should parse the criteria' do
              expect(parse_criteria(&block)).to be == expected
            end

            include_examples 'should print a deprecation warning for',
              'less_than'
          end

          describe 'with a Hash with a "less_than_or_equal_to" operator' do
            let(:block) do
              -> { { 'published_at' => less_than_or_equal_to('1970-01-01') } }
            end
            let(:expected) do
              [['published_at', operators::LESS_THAN_OR_EQUAL_TO, '1970-01-01']]
            end

            it 'should parse the criteria' do
              expect(parse_criteria(&block)).to be == expected
            end

            include_examples 'should print a deprecation warning for',
              'less_than_or_equal_to'
          end

          describe 'with a Hash with a "lt" operator' do
            let(:block) do
              -> { { 'published_at' => lt('1970-01-01') } }
            end
            let(:expected) do
              [['published_at', operators::LESS_THAN, '1970-01-01']]
            end

            it 'should parse the criteria' do
              expect(parse_criteria(&block)).to be == expected
            end

            include_examples 'should print a deprecation warning for', 'lt'
          end

          describe 'with a Hash with a "lte" operator' do
            let(:block) do
              -> { { 'published_at' => lte('1970-01-01') } }
            end
            let(:expected) do
              [['published_at', operators::LESS_THAN_OR_EQUAL_TO, '1970-01-01']]
            end

            it 'should parse the criteria' do
              expect(parse_criteria(&block)).to be == expected
            end

            include_examples 'should print a deprecation warning for', 'lte'
          end

          describe 'with a Hash with a "ne" operator' do
            let(:block) do
              -> { { 'series' => ne('Earthsea') } }
            end
            let(:expected) do
              [['series', operators::NOT_EQUAL, 'Earthsea']]
            end

            it 'should parse the criteria' do
              expect(parse_criteria(&block)).to be == expected
            end

            include_examples 'should print a deprecation warning for', 'ne'
          end

          describe 'with a Hash with a "not_equal" operator' do
            let(:block) do
              -> { { 'series' => not_equal('Earthsea') } }
            end
            let(:expected) do
              [['series', operators::NOT_EQUAL, 'Earthsea']]
            end

            it 'should parse the criteria' do
              expect(parse_criteria(&block)).to be == expected
            end

            include_examples 'should print a deprecation warning for',
              'not_equal'
          end

          describe 'with a Hash with a "not_one_of" operator and an Array' do
            let(:block) do
              lambda do
                {
                  'series' => not_one_of(
                    ['Earthsea', 'The Lord of the Rings']
                  )
                }
              end
            end
            let(:expected) do
              [
                [
                  'series',
                  operators::NOT_ONE_OF,
                  ['Earthsea', 'The Lord of the Rings']
                ]
              ]
            end

            it 'should parse the criteria' do
              expect(parse_criteria(&block)).to be == expected
            end

            include_examples 'should print a deprecation warning for',
              'not_one_of'
          end

          describe 'with a Hash with a "not_one_of" operator and values' do
            let(:block) do
              lambda do
                { 'series' => not_one_of('Earthsea', 'The Lord of the Rings') }
              end
            end
            let(:expected) do
              [
                [
                  'series',
                  operators::NOT_ONE_OF,
                  ['Earthsea', 'The Lord of the Rings']
                ]
              ]
            end

            it 'should parse the criteria' do
              expect(parse_criteria(&block)).to be == expected
            end

            include_examples 'should print a deprecation warning for',
              'not_one_of'
          end

          describe 'with a Hash with a "one_of" operator and an Array' do
            let(:block) do
              lambda do
                { 'series' => one_of(['Earthsea', 'The Lord of the Rings']) }
              end
            end
            let(:expected) do
              [
                [
                  'series',
                  operators::ONE_OF,
                  ['Earthsea', 'The Lord of the Rings']
                ]
              ]
            end

            it 'should parse the criteria' do
              expect(parse_criteria(&block)).to be == expected
            end

            include_examples 'should print a deprecation warning for', 'one_of'
          end

          describe 'with a Hash with a "one_of" operator and values' do
            let(:block) do
              lambda do
                { 'series' => one_of('Earthsea', 'The Lord of the Rings') }
              end
            end
            let(:expected) do
              [
                [
                  'series',
                  operators::ONE_OF,
                  ['Earthsea', 'The Lord of the Rings']
                ]
              ]
            end

            it 'should parse the criteria' do
              expect(parse_criteria(&block)).to be == expected
            end

            include_examples 'should print a deprecation warning for', 'one_of'
          end

          describe 'with a Hash with an unknown operator' do
            let(:error_class) do
              Cuprum::Collections::Queries::UnknownOperatorException
            end
            let(:error_message) do
              'unknown operator "random"'
            end
            let(:block) do
              -> { { 'genre' => random('Science Fiction', 'Fantasy') } }
            end

            it 'should raise an exception' do
              expect { parse_criteria(&block) }
                .to raise_error error_class, error_message
            end

            it 'should preserve the original exception', :aggregate_failures do
              parse_criteria(&block)
            rescue error_class => exception
              expect(exception.cause).to be_a NameError
              expect(exception.name).to be == :random
            end
          end
        end
      end
    end

    # Contract validating the parsing of criteria from a Hash.
    module ShouldParseCriteriaFromAHashContract
      extend RSpec::SleepingKingStudios::Contract

      # @!method apply(example_group)
      #   Adds the contract to the example group.
      #
      #   @param example_group [RSpec::Core::ExampleGroup] the example group to
      #     which the contract is applied.
      contract do
        describe 'with nil' do
          let(:error_message) do
            'value must be a Hash with String or Symbol keys'
          end

          it 'should raise an exception' do
            expect { parse_criteria(nil) }
              .to raise_error ArgumentError, error_message
          end
        end

        describe 'with an Object' do
          let(:error_message) do
            'value must be a Hash with String or Symbol keys'
          end

          it 'should raise an exception' do
            expect { parse_criteria(Object.new.freeze) }
              .to raise_error ArgumentError, error_message
          end
        end

        describe 'with a Hash with invalid keys' do
          let(:error_message) do
            'value must be a Hash with String or Symbol keys'
          end
          let(:value)         { { nil => 'invalid' } }

          it 'should raise an exception' do
            expect { parse_criteria(value) }
              .to raise_error ArgumentError, error_message
          end
        end

        describe 'with an empty Hash' do
          let(:value) { {} }

          it { expect(parse_criteria(value)).to be == [] }
        end

        describe 'with a Hash with one key' do
          let(:operators) { Cuprum::Collections::Queries::Operators }
          let(:value) do
            { 'title' => 'A Wizard of Earthsea' }
          end
          let(:expected) do
            [['title', operators::EQUAL, 'A Wizard of Earthsea']]
          end

          it { expect(parse_criteria(value)).to be == expected }
        end

        describe 'with a Hash with many String keys' do
          let(:operators) { Cuprum::Collections::Queries::Operators }
          let(:value) do
            {
              'title'  => 'A Wizard of Earthsea',
              'author' => 'Ursula K. LeGuin',
              'series' => 'Earthsea'
            }
          end
          let(:expected) do
            [
              ['title', operators::EQUAL, 'A Wizard of Earthsea'],
              ['author', operators::EQUAL, 'Ursula K. LeGuin'],
              ['series', operators::EQUAL, 'Earthsea']
            ]
          end

          it { expect(parse_criteria(value)).to be == expected }
        end

        describe 'with a Hash with many Symbol keys' do
          let(:operators) { Cuprum::Collections::Queries::Operators }
          let(:value) do
            {
              title:  'A Wizard of Earthsea',
              author: 'Ursula K. LeGuin',
              series: 'Earthsea'
            }
          end
          let(:expected) do
            [
              ['title', operators::EQUAL, 'A Wizard of Earthsea'],
              ['author', operators::EQUAL, 'Ursula K. LeGuin'],
              ['series', operators::EQUAL, 'Earthsea']
            ]
          end

          it { expect(parse_criteria(value)).to be == expected }
        end
      end
    end
  end
end
