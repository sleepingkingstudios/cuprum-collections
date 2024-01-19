# frozen_string_literal: true

require 'cuprum/collections/queries'
require 'cuprum/collections/rspec/contracts'
require 'cuprum/collections/rspec/fixtures'

module Cuprum::Collections::RSpec::Contracts
  # Contracts for asserting on Query objects.
  module QueryContracts
    # Contract validating the behavior of a Query implementation.
    module ShouldBeAQuery
      extend RSpec::SleepingKingStudios::Contract

      BOOKS_FIXTURES = Cuprum::Collections::RSpec::Fixtures::BOOKS_FIXTURES
      private_constant :BOOKS_FIXTURES

      OPERATORS = Cuprum::Collections::Queries::Operators
      private_constant :OPERATORS

      # @!method apply(example_group, abstract: false)
      #   Adds the contract to the example group.
      #
      #   @param example_group [RSpec::Core::ExampleGroup] the example group to
      #     which the contract is applied.
      #   @param abstract [Boolean] if true, the query does not implement
      #     methods for operating on a collection. Defaults to false.
      contract do |abstract: false|
        include Cuprum::Collections::RSpec::Contracts::QueryContracts

        shared_context 'when initialized with a scope' do
          let(:initial_scope) do
            Cuprum::Collections::Scope.new do
              { 'published_at' => less_than('1973-01-01') }
            end
          end
          let(:matching_data) do
            super().select { |item| item['published_at'] < '1973-01-01' }
          end
        end

        shared_context 'when the query has composed filters' do
          let(:scoped_query) do
            super()
              .where { { author: 'Ursula K. LeGuin' } }
              .where { { series: not_equal('Earthsea') } }
          end
          let(:matching_data) do
            super()
              .select { |item| item['author'] == 'Ursula K. LeGuin' }
              .reject { |item| item['series'] == 'Earthsea' }
          end
        end

        let(:scoped_query) do
          scoped =
            if scope.is_a?(Proc)
              subject.where(&scope)
            else
              subject
            end
          scoped = scoped.limit(limit)   if limit
          scoped = scoped.offset(offset) if offset
          scoped = scoped.order(order)   if order

          scoped
        end

        include_contract 'with query contexts'

        it 'should be enumerable' do
          expect(described_class).to be < Enumerable
        end

        describe '#count' do
          let(:data)          { [] }
          let(:matching_data) { data }
          let(:expected_data) do
            defined?(super()) ? super() : matching_data
          end

          it { expect(query).to respond_to(:count).with(0).arguments }

          next if abstract

          it { expect(query.count).to be == expected_data.count }

          wrap_context 'when initialized with a scope' do
            it { expect(scoped_query.count).to be == expected_data.count }

            wrap_context 'when the query has composed filters' do
              it { expect(scoped_query.count).to be == expected_data.count }
            end
          end

          wrap_context 'when the query has composed filters' do
            it { expect(scoped_query.count).to be == expected_data.count }
          end

          context 'when the collection data changes' do
            let(:item) { BOOKS_FIXTURES.first }

            before(:example) do
              query.count # Cache query results.

              add_item_to_collection(item)
            end

            it { expect(query.count).to be == expected_data.count }
          end

          context 'when the collection has many items' do
            let(:data) { BOOKS_FIXTURES }

            it { expect(query.count).to be == expected_data.count }

            wrap_context 'when initialized with a scope' do
              it { expect(scoped_query.count).to be == expected_data.count }

              wrap_context 'when the query has composed filters' do
                it { expect(scoped_query.count).to be == expected_data.count }
              end
            end

            wrap_context 'when the query has composed filters' do
              it { expect(scoped_query.count).to be == expected_data.count }
            end

            context 'when the collection data changes' do
              let(:data) { BOOKS_FIXTURES[0...-1] }
              let(:item) { BOOKS_FIXTURES.last }

              before(:example) do
                query.count # Cache query results.

                add_item_to_collection(item)
              end

              it { expect(query.count).to be == expected_data.count }
            end
          end
        end

        describe '#each' do
          shared_examples 'should enumerate the matching data' do
            describe 'with no arguments' do
              it { expect(scoped_query.each).to be_a Enumerator }

              it { expect(scoped_query.each.count).to be == matching_data.size }

              it { expect(scoped_query.each.to_a).to deep_match expected_data }
            end

            describe 'with a block' do
              it 'should yield each matching item' do
                expect { |block| scoped_query.each(&block) }
                  .to yield_successive_args(*expected_data)
              end
            end
          end

          let(:data)          { [] }
          let(:matching_data) { data }
          let(:expected_data) do
            defined?(super()) ? super() : matching_data
          end

          next if abstract

          it { expect(query).to respond_to(:each).with(0).arguments }

          include_examples 'should enumerate the matching data'

          include_contract 'should perform queries',
            block: -> { include_examples 'should enumerate the matching data' }

          wrap_context 'when initialized with a scope' do
            include_examples 'should enumerate the matching data'

            wrap_context 'when the query has composed filters' do
              include_examples 'should enumerate the matching data'
            end
          end

          wrap_context 'when the query has composed filters' do
            include_examples 'should enumerate the matching data'
          end

          context 'when the collection data changes' do
            let(:item) { BOOKS_FIXTURES.first }

            before(:example) do
              query.each {} # Cache query results.

              add_item_to_collection(item)
            end

            include_examples 'should enumerate the matching data'
          end

          context 'when the collection has many items' do
            let(:data) { BOOKS_FIXTURES }

            include_examples 'should enumerate the matching data'

            include_contract 'should perform queries',
              block: lambda {
                include_examples 'should enumerate the matching data'
              }

            wrap_context 'when initialized with a scope' do
              include_examples 'should enumerate the matching data'

              wrap_context 'when the query has composed filters' do
                include_examples 'should enumerate the matching data'
              end
            end

            wrap_context 'when the query has composed filters' do
              include_examples 'should enumerate the matching data'
            end

            context 'when the collection data changes' do
              let(:data) { BOOKS_FIXTURES[0...-1] }
              let(:item) { BOOKS_FIXTURES.last }

              before(:example) do
                query.each {} # Cache query results.

                add_item_to_collection(item)
              end

              include_examples 'should enumerate the matching data'
            end
          end
        end

        describe '#exists?' do
          shared_examples 'should check the existence of matching data' do
            it { expect(query.exists?).to be == !matching_data.empty? }
          end

          let(:data)          { [] }
          let(:matching_data) { data }

          next if abstract

          include_examples 'should define predicate', :exists?

          include_examples 'should check the existence of matching data'

          include_contract 'should perform queries',
            block: lambda {
              include_examples 'should check the existence of matching data'
            }

          wrap_context 'when initialized with a scope' do
            include_examples 'should check the existence of matching data'

            wrap_context 'when the query has composed filters' do
              include_examples 'should check the existence of matching data'
            end
          end

          wrap_context 'when the query has composed filters' do
            include_examples 'should check the existence of matching data'
          end

          context 'when the collection has many items' do
            let(:data) { BOOKS_FIXTURES }

            include_examples 'should check the existence of matching data'

            include_contract 'should perform queries',
              block: lambda {
                include_examples 'should check the existence of matching data'
              }

            wrap_context 'when initialized with a scope' do
              include_examples 'should check the existence of matching data'

              wrap_context 'when the query has composed filters' do
                include_examples 'should check the existence of matching data'
              end
            end

            wrap_context 'when the query has composed filters' do
              include_examples 'should check the existence of matching data'
            end
          end
        end

        describe '#limit' do
          it { expect(query).to respond_to(:limit).with(0..1).arguments }

          describe 'with no arguments' do
            it { expect(query.limit).to be nil }
          end

          describe 'with nil' do
            let(:error_message) { 'limit must be a non-negative integer' }

            it 'should raise an exception' do
              expect { query.limit nil }
                .to raise_error ArgumentError, error_message
            end
          end

          describe 'with an object' do
            let(:error_message) { 'limit must be a non-negative integer' }

            it 'should raise an exception' do
              expect { query.limit Object.new.freeze }
                .to raise_error ArgumentError, error_message
            end
          end

          describe 'with a negative integer' do
            let(:error_message) { 'limit must be a non-negative integer' }

            it 'should raise an exception' do
              expect { query.limit(-1) }
                .to raise_error ArgumentError, error_message
            end
          end

          describe 'with zero' do
            it { expect(query.limit(0)).to be_a described_class }

            it { expect(query.limit(0)).not_to be query }

            it { expect(query.limit(0).limit).to be 0 }
          end

          describe 'with a positive integer' do
            it { expect(query.limit(3)).to be_a described_class }

            it { expect(query.limit(3)).not_to be query }

            it { expect(query.limit(3).limit).to be 3 }
          end
        end

        describe '#offset' do
          it { expect(query).to respond_to(:offset).with(0..1).argument }

          describe 'with no arguments' do
            it { expect(query.offset).to be nil }
          end

          describe 'with nil' do
            let(:error_message) { 'offset must be a non-negative integer' }

            it 'should raise an exception' do
              expect { query.offset nil }
                .to raise_error ArgumentError, error_message
            end
          end

          describe 'with an object' do
            let(:error_message) { 'offset must be a non-negative integer' }

            it 'should raise an exception' do
              expect { query.offset Object.new.freeze }
                .to raise_error ArgumentError, error_message
            end
          end

          describe 'with a negative integer' do
            let(:error_message) { 'offset must be a non-negative integer' }

            it 'should raise an exception' do
              expect { query.offset(-1) }
                .to raise_error ArgumentError, error_message
            end
          end

          describe 'with zero' do
            it { expect(query.offset(0)).to be_a described_class }

            it { expect(query.offset(0)).not_to be query }

            it { expect(query.offset(0).offset).to be 0 }
          end

          describe 'with a positive integer' do
            it { expect(query.offset(3)).to be_a described_class }

            it { expect(query.offset(3)).not_to be query }

            it { expect(query.offset(3).offset).to be 3 }
          end
        end

        describe '#order' do
          let(:default_order) { defined?(super()) ? super() : {} }
          let(:error_message) do
            'order must be a list of attribute names and/or a hash of ' \
              'attribute names with values :asc or :desc'
          end

          it 'should define the method' do
            expect(query)
              .to respond_to(:order)
              .with(0).arguments
              .and_unlimited_arguments
          end

          it { expect(query).to have_aliased_method(:order).as(:order_by) }

          describe 'with no arguments' do
            it { expect(query.order).to be == default_order }
          end

          describe 'with a hash with invalid keys' do
            it 'should raise an exception' do
              expect { query.order({ nil => :asc }) }
                .to raise_error ArgumentError, error_message
            end
          end

          describe 'with a hash with empty string keys' do
            it 'should raise an exception' do
              expect { query.order({ '' => :asc }) }
                .to raise_error ArgumentError, error_message
            end
          end

          describe 'with a hash with empty symbol keys' do
            it 'should raise an exception' do
              expect { query.order({ '': :asc }) }
                .to raise_error ArgumentError, error_message
            end
          end

          describe 'with a hash with nil value' do
            it 'should raise an exception' do
              expect { query.order({ title: nil }) }
                .to raise_error ArgumentError, error_message
            end
          end

          describe 'with a hash with object value' do
            it 'should raise an exception' do
              expect { query.order({ title: Object.new.freeze }) }
                .to raise_error ArgumentError, error_message
            end
          end

          describe 'with a hash with empty value' do
            it 'should raise an exception' do
              expect { query.order({ title: '' }) }
                .to raise_error ArgumentError, error_message
            end
          end

          describe 'with a hash with invalid value' do
            it 'should raise an exception' do
              expect { query.order({ title: 'wibbly' }) }
                .to raise_error ArgumentError, error_message
            end
          end

          describe 'with a valid ordering' do
            let(:expected) do
              { title: :asc }
            end

            it { expect(query.order(:title)).to be_a described_class }

            it { expect(query.order(:title)).not_to be query }

            it { expect(query.order(:title).order).to be == expected }
          end
        end

        describe '#reset' do
          let(:data)          { [] }
          let(:matching_data) { data }
          let(:expected_data) do
            defined?(super()) ? super() : matching_data
          end

          it { expect(query).to respond_to(:reset).with(0).arguments }

          it { expect(query.reset).to be_a query.class }

          it { expect(query.reset).not_to be query }

          next if abstract

          it { expect(query.reset.to_a).to be == query.to_a }

          context 'when the collection data changes' do
            let(:item)          { BOOKS_FIXTURES.first }
            let(:matching_data) { [item] }

            before(:example) do
              query.to_a # Cache query results.

              add_item_to_collection(item)
            end

            it { expect(query.reset.count).to be expected_data.size }

            it { expect(query.reset.to_a).to deep_match expected_data }
          end

          context 'when the collection has many items' do
            let(:data) { BOOKS_FIXTURES }

            it { expect(query.reset).to be_a query.class }

            it { expect(query.reset).not_to be query }

            it { expect(query.reset.to_a).to be == query.to_a }

            context 'when the collection data changes' do
              let(:data)          { BOOKS_FIXTURES[0...-1] }
              let(:item)          { BOOKS_FIXTURES.last }
              let(:matching_data) { [*data, item] }

              before(:example) do
                query.to_a # Cache query results.

                add_item_to_collection(item)
              end

              it { expect(query.reset.count).to be expected_data.size }

              it { expect(query.reset.to_a).to deep_match expected_data }
            end
          end
        end

        describe '#scope' do
          include_examples 'should define reader', :scope

          it { expect(query.scope).to be_a Cuprum::Collections::Scopes::Base }

          it { expect(query.scope.type).to be :null }

          wrap_context 'when initialized with a scope' do
            let(:expected) do
              Cuprum::Collections::Scope.new do
                {
                  'published_at' => less_than('1973-01-01')
                }
              end
            end

            it { expect(scoped_query.scope).to be == expected }

            wrap_context 'when the query has composed filters' do
              let(:expected) do
                Cuprum::Collections::Scope.new do
                  {
                    'published_at' => less_than('1973-01-01'),
                    'author'       => 'Ursula K. LeGuin',
                    'series'       => not_equal('Earthsea')
                  }
                end
              end

              it { expect(scoped_query.scope).to be == expected }
            end
          end

          wrap_context 'when the query has composed filters' do
            let(:expected) do
              Cuprum::Collections::Scope.new do
                {
                  'author' => 'Ursula K. LeGuin',
                  'series' => not_equal('Earthsea')
                }
              end
            end

            it { expect(scoped_query.scope).to be == expected }
          end
        end

        describe '#to_a' do
          let(:data)          { [] }
          let(:matching_data) { data }
          let(:expected_data) do
            defined?(super()) ? super() : matching_data
          end

          it { expect(query).to respond_to(:to_a).with(0).arguments }

          next if abstract

          it { expect(query.to_a).to deep_match expected_data }

          include_contract 'should perform queries',
            block: lambda {
              it { expect(scoped_query.to_a).to deep_match expected_data }
            }

          wrap_context 'when initialized with a scope' do
            it { expect(scoped_query.to_a).to deep_match expected_data }

            wrap_context 'when the query has composed filters' do
              it { expect(scoped_query.to_a).to deep_match expected_data }
            end
          end

          wrap_context 'when the query has composed filters' do
            it { expect(scoped_query.to_a).to deep_match expected_data }
          end

          context 'when the collection data changes' do
            let(:item) { BOOKS_FIXTURES.first }

            before(:example) do
              query.to_a # Cache query results.

              add_item_to_collection(item)
            end

            it { expect(query.to_a).to deep_match expected_data }
          end

          context 'when the collection has many items' do
            let(:data) { BOOKS_FIXTURES }

            it { expect(query.to_a).to deep_match expected_data }

            include_contract 'should perform queries',
              block: lambda {
                it { expect(scoped_query.to_a).to deep_match expected_data }
              }

            wrap_context 'when initialized with a scope' do
              it { expect(scoped_query.to_a).to deep_match expected_data }

              wrap_context 'when the query has composed filters' do
                it { expect(scoped_query.to_a).to deep_match expected_data }
              end
            end

            wrap_context 'when the query has composed filters' do
              it { expect(scoped_query.to_a).to deep_match expected_data }
            end

            context 'when the collection data changes' do
              let(:data) { BOOKS_FIXTURES[0...-1] }
              let(:item) { BOOKS_FIXTURES.last }

              before(:example) do
                query.to_a # Cache query results.

                add_item_to_collection(item)
              end

              it { expect(query.to_a).to deep_match expected_data }
            end
          end
        end

        describe '#where' do
          let(:block) { -> { { title: 'Gideon the Ninth' } } }

          it 'should define the method' do
            expect(subject)
              .to respond_to(:where)
              .with(0..1).arguments
              .and_a_block
          end

          it { expect(subject.where(&block)).to be_a described_class }

          it { expect(subject.where(&block)).not_to be subject }

          it 'should set the scope' do
            expect(subject.where(&block).scope)
              .to be_a Cuprum::Collections::Scopes::Base
          end

          it 'should not change the original query scope' do
            expect { subject.where(&block) }
              .not_to change(subject, :scope)
          end

          context 'when the query does not have a scope' do
            let(:expected) do
              Cuprum::Collections::Scope.new({ 'title' => 'Gideon the Ninth' })
            end

            describe 'with a block' do
              let(:block) { -> { { 'title' => 'Gideon the Ninth' } } }

              it { expect(subject.where(&block).scope).to be == expected }
            end

            describe 'with a hash' do
              let(:value) { { 'title' => 'Gideon the Ninth' } }

              it { expect(subject.where(value).scope).to be == expected }
            end

            describe 'with a basic scope' do
              let(:value) do
                Cuprum::Collections::Scope
                  .new({ 'title' => 'Gideon the Ninth' })
              end

              it { expect(subject.where(value).scope).to be == value }
            end

            describe 'with a complex scope' do
              let(:value) do
                Cuprum::Collections::Scope
                  .new({ 'title' => 'Gideon the Ninth' })
                  .or({ 'title' => 'Harrow the Ninth' })
              end

              it { expect(subject.where(value).scope).to be == value }
            end
          end

          context 'when the query has a scope' do
            let(:initial_scope) do
              Cuprum::Collections::Scope.new({ 'author' => 'Tamsyn Muir' })
            end
            let(:expected) do
              operators = Cuprum::Collections::Queries::Operators

              [
                [
                  'author',
                  operators::EQUAL,
                  'Tamsyn Muir'
                ],
                [
                  'title',
                  operators::EQUAL,
                  'Gideon the Ninth'
                ]
              ]
            end

            describe 'with a block' do
              let(:block) { -> { { 'title' => 'Gideon the Ninth' } } }
              let(:scope) { subject.where(&block).scope }

              it { expect(scope).to be_a Cuprum::Collections::Scopes::Base }

              it { expect(scope.type).to be :criteria }

              it { expect(scope.criteria).to be == expected }
            end

            describe 'with a value' do
              let(:value) { { 'title' => 'Gideon the Ninth' } }
              let(:scope) { subject.where(value).scope }

              it { expect(scope).to be_a Cuprum::Collections::Scopes::Base }

              it { expect(scope.type).to be :criteria }

              it { expect(scope.criteria).to be == expected }
            end

            describe 'with a basic scope' do
              let(:value) do
                Cuprum::Collections::Scope
                  .new({ 'title' => 'Gideon the Ninth' })
              end
              let(:scope) { subject.where(value).scope }

              it { expect(scope).to be_a Cuprum::Collections::Scopes::Base }

              it { expect(scope.type).to be :criteria }

              it { expect(scope.criteria).to be == expected }
            end

            describe 'with a complex scope' do
              let(:value) do
                Cuprum::Collections::Scope
                  .new({ 'title' => 'Gideon the Ninth' })
                  .or({ 'title' => 'Harrow the Ninth' })
              end
              let(:scope) { subject.where(value).scope }
              let(:outer) { scope.scopes.last }
              let(:expected) do
                operators = Cuprum::Collections::Queries::Operators

                [
                  [
                    'author',
                    operators::EQUAL,
                    'Tamsyn Muir'
                  ]
                ]
              end
              let(:expected_first) do
                operators = Cuprum::Collections::Queries::Operators

                [
                  [
                    'title',
                    operators::EQUAL,
                    'Gideon the Ninth'
                  ]
                ]
              end
              let(:expected_second) do
                operators = Cuprum::Collections::Queries::Operators

                [
                  [
                    'title',
                    operators::EQUAL,
                    'Harrow the Ninth'
                  ]
                ]
              end

              it { expect(scope).to be_a Cuprum::Collections::Scopes::Base }

              it { expect(scope.type).to be :conjunction }

              it { expect(scope.scopes.size).to be 2 }

              it { expect(scope.scopes.first.type).to be :criteria }

              it { expect(scope.scopes.first.criteria).to be == expected }

              it { expect(outer).to be_a Cuprum::Collections::Scopes::Base }

              it { expect(outer.type).to be :disjunction }

              it { expect(outer.scopes.size).to be 2 }

              it { expect(outer.scopes.first.criteria).to be == expected_first }

              it { expect(outer.scopes.last.criteria).to be == expected_second }
            end
          end
        end
      end
    end

    # Contract validating the behavior when performing queries.
    module ShouldPerformQueriesContract
      extend RSpec::SleepingKingStudios::Contract

      OPERATORS = Cuprum::Collections::Queries::Operators
      private_constant :OPERATORS

      # @!method apply(example_group, block:, operators:)
      #   Adds the contract to the example group.
      #
      #   @param example_group [RSpec::Core::ExampleGroup] the example group to
      #     which the contract is applied.
      #   @param block [Proc] the expectations for each query context.
      #   @param operators [Array<Symbol>] the expected operators.
      contract do |block:, operators: OPERATORS.values|
        operators = Set.new(operators.map(&:to_sym))

        wrap_context 'when the query has limit: value' do
          instance_exec(&block)
        end

        wrap_context 'when the query has offset: value' do
          instance_exec(&block)
        end

        wrap_context 'when the query has order: a simple ordering' do
          instance_exec(&block)
        end

        wrap_context 'when the query has order: a complex ordering' do
          instance_exec(&block)
        end

        context 'when the query has where: a block filter' do
          context 'with a simple filter' do
            include_context 'when the query has where: a simple block filter'

            instance_exec(&block)
          end

          context 'with a complex filter' do
            include_context 'when the query has where: a complex block filter'

            if operators.include?(OPERATORS::EQUAL) &&
               operators.include?(OPERATORS::NOT_EQUAL)
              instance_exec(&block)
            else
              # :nocov:
              pending
              # :nocov:
            end
          end

          context 'with an equals filter' do
            include_context 'when the query has where: an equal block filter'

            if operators.include?(OPERATORS::EQUAL)
              instance_exec(&block)
            else
              # :nocov:
              pending
              # :nocov:
            end
          end

          context 'with a greater_than filter' do
            include_context 'when the query has where: a greater_than filter'

            if operators.include?(OPERATORS::GREATER_THAN)
              instance_exec(&block)
            else
              # :nocov:
              pending
              # :nocov:
            end
          end

          context 'with a greater_than_or_equal_to filter' do
            include_context \
              'when the query has where: a greater_than_or_equal_to filter'

            if operators.include?(OPERATORS::GREATER_THAN_OR_EQUAL_TO)
              instance_exec(&block)
            else
              # :nocov:
              pending
              # :nocov:
            end
          end

          context 'with a less_than filter' do
            include_context 'when the query has where: a less_than filter'

            if operators.include?(OPERATORS::LESS_THAN)
              instance_exec(&block)
            else
              # :nocov:
              pending
              # :nocov:
            end
          end

          context 'with a less_than_or_equal_to filter' do
            include_context \
              'when the query has where: a less_than_or_equal_to filter'

            if operators.include?(OPERATORS::LESS_THAN_OR_EQUAL_TO)
              instance_exec(&block)
            else
              # :nocov:
              pending
              # :nocov:
            end
          end

          context 'with a not_equal filter' do
            include_context 'when the query has where: a not_equal block filter'

            if operators.include?(OPERATORS::NOT_EQUAL)
              instance_exec(&block)
            else
              # :nocov:
              pending
              # :nocov:
            end
          end

          context 'with a not_one_of filter' do
            include_context \
              'when the query has where: a not_one_of block filter'

            if operators.include?(OPERATORS::NOT_ONE_OF)
              instance_exec(&block)
            else
              # :nocov:
              pending
              # :nocov:
            end
          end

          context 'with a one_of filter' do
            include_context 'when the query has where: a one_of block filter'

            if operators.include?(OPERATORS::ONE_OF)
              instance_exec(&block)
            else
              # :nocov:
              pending
              # :nocov:
            end
          end
        end

        wrap_context 'when the query has multiple query options' do
          instance_exec(&block)
        end
      end
    end

    # Contract defining contexts for validating query behavior.
    module WithQueryContextsContract
      extend RSpec::SleepingKingStudios::Contract

      # @!method apply(example_group)
      #   Adds the contract to the example group.
      #
      #   @param example_group [RSpec::Core::ExampleGroup] the example group to
      #     which the contract is applied.
      contract do
        let(:scope)  { nil }
        let(:limit)  { nil }
        let(:offset) { nil }
        let(:order)  { nil }

        shared_context 'when the query has limit: value' do
          let(:limit)         { 3 }
          let(:matching_data) { super()[0...limit] }
        end

        shared_context 'when the query has offset: value' do
          let(:offset)        { 2 }
          let(:matching_data) { super()[offset..] || [] }
        end

        shared_context 'when the query has order: a simple ordering' do
          let(:order)         { :title }
          let(:matching_data) { super().sort_by { |item| item['title'] } }
        end

        shared_context 'when the query has order: a complex ordering' do
          let(:order) do
            {
              author: :asc,
              title:  :desc
            }
          end
          let(:matching_data) do
            super().sort do |u, v|
              cmp = u['author'] <=> v['author']

              cmp.zero? ? (v['title'] <=> u['title']) : cmp
            end
          end
        end

        shared_context 'when the query has where: a simple block filter' do
          let(:filter) { -> { { author: 'Ursula K. LeGuin' } } }
          let(:scope)  { filter }
          let(:matching_data) do
            super().select { |item| item['author'] == 'Ursula K. LeGuin' }
          end
        end

        shared_context 'when the query has where: a complex block filter' do
          let(:filter) do
            lambda do
              {
                author: equals('Ursula K. LeGuin'),
                series: not_equal('Earthsea')
              }
            end
          end
          let(:scope) { filter }
          let(:matching_data) do
            super()
              .select { |item| item['author'] == 'Ursula K. LeGuin' }
              .reject { |item| item['series'] == 'Earthsea' }
          end
        end

        shared_context 'when the query has where: a greater_than filter' do
          let(:filter) { -> { { published_at: greater_than('1970-12-01') } } }
          let(:scope)  { filter }
          let(:matching_data) do
            super().select { |item| item['published_at'] > '1970-12-01' }
          end
        end

        shared_context 'when the query has where: a greater_than_or_equal_to ' \
                       'filter' \
        do
          let(:filter) do
            -> { { published_at: greater_than_or_equal_to('1970-12-01') } }
          end
          let(:scope) { filter }
          let(:matching_data) do
            super().select { |item| item['published_at'] >= '1970-12-01' }
          end
        end

        shared_context 'when the query has where: a less_than filter' do
          let(:filter) { -> { { published_at: less_than('1970-12-01') } } }
          let(:scope)  { filter }
          let(:matching_data) do
            super().select { |item| item['published_at'] < '1970-12-01' }
          end
        end

        shared_context 'when the query has where: a ' \
                       'less_than_or_equal_to filter' \
        do
          let(:filter) do
            -> { { published_at: less_than_or_equal_to('1970-12-01') } }
          end
          let(:scope) { filter }
          let(:matching_data) do
            super().select { |item| item['published_at'] <= '1970-12-01' }
          end
        end

        shared_context 'when the query has where: an equal block filter' do
          let(:filter) { -> { { author: equals('Ursula K. LeGuin') } } }
          let(:scope)  { filter }
          let(:matching_data) do
            super().select { |item| item['author'] == 'Ursula K. LeGuin' }
          end
        end

        shared_context 'when the query has where: a not_equal block filter' do
          let(:filter) { -> { { author: not_equal('Ursula K. LeGuin') } } }
          let(:scope)  { filter }
          let(:matching_data) do
            super().reject { |item| item['author'] == 'Ursula K. LeGuin' }
          end
        end

        shared_context 'when the query has where: a not_one_of block filter' do
          let(:filter) do
            -> { { series: not_one_of(['Earthsea', 'The Lord of the Rings']) } }
          end
          let(:scope) { filter }
          let(:matching_data) do
            super().reject do |item|
              ['Earthsea', 'The Lord of the Rings'].include?(item['series'])
            end
          end
        end

        shared_context 'when the query has where: a one_of block filter' do
          let(:filter) do
            -> { { series: one_of(['Earthsea', 'The Lord of the Rings']) } }
          end
          let(:scope) { filter }
          let(:matching_data) do
            super().select do |item|
              ['Earthsea', 'The Lord of the Rings'].include?(item['series'])
            end
          end
        end

        shared_context 'when the query has multiple query options' do
          let(:filter) { -> { { author: 'Ursula K. LeGuin' } } }
          let(:scope)  { filter }
          let(:order)  { { title: :desc } }
          let(:limit)  { 2 }
          let(:offset) { 1 }
          let(:matching_data) do
            super()
              .select { |item| item['author'] == 'Ursula K. LeGuin' }
              .sort { |u, v| v['title'] <=> u['title'] }
              .slice(1, 2) || []
          end
        end
      end
    end
  end
end
