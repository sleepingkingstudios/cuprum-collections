# frozen_string_literal: true

require 'cuprum/collections/queries'
require 'cuprum/collections/rspec/contracts'
require 'cuprum/collections/rspec/deferred/query_examples'
require 'cuprum/collections/rspec/fixtures'

module Cuprum::Collections::RSpec::Contracts
  # Contracts for asserting on Query objects.
  module QueryContracts
    include Cuprum::Collections::RSpec::Deferred::QueryExamples

    # Contract validating the behavior of a Query implementation.
    #
    # @deprecated 0.6.0
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

        SleepingKingStudios::Tools::CoreTools.deprecate(
          'QueryContracts "should be a query"',
          message: 'Use Deferred::QueryExamples instead.'
        )

        shared_context 'when initialized with a scope' do
          let(:initial_scope) do
            Cuprum::Collections::Scope.new do |scope|
              { 'published_at' => scope.less_than('1973-01-01') }
            end
          end
          let(:filtered_data) do
            super().select { |item| item['published_at'] < '1973-01-01' }
          end
        end

        shared_context 'when the query has composed filters' do
          let(:scoped_query) do
            super()
              .where { { author: 'Ursula K. LeGuin' } }
              .where { |scope| { series: scope.not_equal('Earthsea') } }
          end
          let(:filtered_data) do
            super()
              .select { |item| item['author'] == 'Ursula K. LeGuin' }
              .reject { |item| item['series'] == 'Earthsea' }
          end
        end

        let(:filter) { nil }
        let(:limit)  { nil }
        let(:offset) { nil }
        let(:order)  { nil }
        let(:scoped_query) do
          scoped =
            if filter.is_a?(Proc)
              subject.where(&filter)
            elsif filter
              subject.where(filter)
            else
              subject
            end
          scoped = scoped.limit(limit)   if limit
          scoped = scoped.offset(offset) if offset
          scoped = scoped.order(order)   if order

          scoped
        end

        it 'should be enumerable' do
          expect(described_class).to be < Enumerable
        end

        describe '#count' do
          it { expect(query).to respond_to(:count).with(0).arguments }

          next if abstract

          it { expect(query.count).to be 0 }

          context 'when the collection data changes' do
            let(:item) { BOOKS_FIXTURES.first }

            before(:example) do
              query.count # Cache query results.

              add_item_to_collection(item)
            end

            it { expect(query.count).to be 0 }
          end

          context 'when the collection has many items' do
            let(:data) { BOOKS_FIXTURES }

            include_deferred 'should query the collection', ignore_order: true \
            do
              it { expect(scoped_query.count).to be == expected_data.count }

              wrap_context 'when the query has composed filters' do
                it { expect(scoped_query.count).to be == expected_data.count }
              end

              wrap_context 'when initialized with a scope' do
                it { expect(scoped_query.count).to be == expected_data.count }

                wrap_context 'when the query has composed filters' do
                  it { expect(scoped_query.count).to be == expected_data.count }
                end
              end
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

              it { expect(scoped_query.each.count).to be == expected_data.size }

              it { expect(scoped_query.each.to_a).to deep_match expected_data }
            end

            describe 'with a block' do
              it 'should yield each matching item' do
                expect { |block| scoped_query.each(&block) }
                  .to yield_successive_args(*expected_data)
              end
            end
          end

          next if abstract

          it { expect(query).to respond_to(:each).with(0).arguments }

          include_examples 'should enumerate the matching data'

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

            include_deferred 'should query the collection' do
              include_examples 'should enumerate the matching data'

              wrap_context 'when the query has composed filters' do
                include_examples 'should enumerate the matching data'
              end

              wrap_context 'when initialized with a scope' do
                include_examples 'should enumerate the matching data'

                wrap_context 'when the query has composed filters' do
                  include_examples 'should enumerate the matching data'
                end
              end
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
            let(:data)          { [] }
            let(:expected_data) { defined?(super()) ? super() : data }

            it { expect(query.exists?).to be == !expected_data.empty? }
          end

          next if abstract

          include_examples 'should define predicate', :exists?

          include_examples 'should check the existence of matching data'

          context 'when the collection has many items' do
            let(:data) { BOOKS_FIXTURES }

            include_deferred 'should query the collection', ignore_order: true \
            do
              include_examples 'should check the existence of matching data'

              wrap_context 'when the query has composed filters' do
                include_examples 'should check the existence of matching data'
              end

              wrap_context 'when initialized with a scope' do
                include_examples 'should check the existence of matching data'

                wrap_context 'when the query has composed filters' do
                  include_examples 'should check the existence of matching data'
                end
              end
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

          it { expect(query.scope.type).to be :all }

          wrap_context 'when initialized with a scope' do
            let(:expected) do
              Cuprum::Collections::Scope.new do |scope|
                {
                  'published_at' => scope.less_than('1973-01-01')
                }
              end
            end

            it { expect(scoped_query.scope).to be == expected }

            wrap_context 'when the query has composed filters' do
              let(:expected) do
                Cuprum::Collections::Scope.new do |scope|
                  {
                    'published_at' => scope.less_than('1973-01-01'),
                    'author'       => 'Ursula K. LeGuin',
                    'series'       => scope.not_equal('Earthsea')
                  }
                end
              end

              it { expect(scoped_query.scope).to be == expected }
            end
          end

          wrap_context 'when the query has composed filters' do
            let(:expected) do
              Cuprum::Collections::Scope.new do |scope|
                {
                  'author' => 'Ursula K. LeGuin',
                  'series' => scope.not_equal('Earthsea')
                }
              end
            end

            it { expect(scoped_query.scope).to be == expected }
          end
        end

        describe '#to_a' do
          let(:data)          { [] }
          let(:queried_data)  { scoped_query.to_a }
          let(:expected_data) { defined?(super()) ? super() : data }

          it { expect(query).to respond_to(:to_a).with(0).arguments }

          next if abstract

          it { expect(queried_data).to be == [] }

          context 'when the collection data changes' do
            let(:item) { BOOKS_FIXTURES.first }

            before(:example) do
              scoped_query.to_a # Cache query results.

              add_item_to_collection(item)
            end

            it { expect(queried_data).to be == [] }
          end

          context 'when the collection has many items' do
            let(:data) { BOOKS_FIXTURES }

            include_deferred 'should query the collection' do
              it { expect(queried_data).to be == expected_data }

              wrap_context 'when the query has composed filters' do
                it { expect(queried_data).to be == expected_data }
              end

              wrap_context 'when initialized with a scope' do
                it { expect(queried_data).to be == expected_data }

                wrap_context 'when the query has composed filters' do
                  it { expect(queried_data).to be == expected_data }
                end
              end
            end

            context 'when the collection data changes' do
              let(:data) { BOOKS_FIXTURES[0...-1] }
              let(:item) { BOOKS_FIXTURES.last }

              before(:example) do
                scoped_query.to_a # Cache query results.

                add_item_to_collection(item)
              end

              it { expect(queried_data).to deep_match expected_data }
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
    #
    # @deprecate 0.6.0 Use Deferred::QueryExamples instead.
    module ShouldQueryTheCollectionContract
      extend RSpec::SleepingKingStudios::Contract

      contract do |*tags, &examples|
        ignore_order = tags.include?(:ignore_order)

        SleepingKingStudios::Tools::CoreTools.deprecate(
          'QueryContracts "should query the collection"',
          message: 'Use Deferred::QueryExamples instead.'
        )

        shared_examples 'should query the collection' do
          # :nocov:
          if examples
            instance_exec(&examples)
          else
            it { expect(queried_data).to be == expected_data }
          end
          # :nocov:
        end

        shared_examples 'should apply limit and offset' do
          include_examples 'should query the collection'

          context 'with limit: value' do
            let(:limit) { 3 }

            include_examples 'should query the collection'
          end

          context 'with offset: value' do
            let(:offset) { 2 }

            include_examples 'should query the collection'
          end

          describe 'with limit: value and offset: value' do
            let(:limit)  { 3 }
            let(:offset) { 2 }

            include_examples 'should query the collection'
          end
        end

        shared_examples 'should order the results' do
          include_examples 'should apply limit and offset'

          next if ignore_order

          describe 'with a simple ordering' do
            let(:order) { 'title' }
            let(:ordered_data) do
              filtered_data.sort_by { |item| item['title'] }
            end

            include_examples 'should apply limit and offset'
          end

          describe 'with a complex ordering' do
            let(:order) do
              {
                'author'       => :desc,
                'published_at' => :asc
              }
            end
            let(:ordered_data) do
              filtered_data.sort do |u, v|
                compare = u['author'] <=> v['author']

                next -compare unless compare.zero?

                u['published_at'] <=> v['published_at']
              end
            end

            include_examples 'should apply limit and offset'
          end
        end

        let(:filter)        { defined?(super()) ? super() : nil }
        let(:limit)         { defined?(super()) ? super() : nil }
        let(:offset)        { defined?(super()) ? super() : nil }
        let(:mapped_data)   { defined?(super()) ? super() : data }
        let(:filtered_data) { mapped_data }
        let(:ordered_data) do
          return super() if defined?(super())

          attr_name = defined?(default_order) ? default_order : 'id'

          filtered_data.sort_by { |item| item[attr_name] }
        end
        let(:matching_data) do
          data = ordered_data
          data = data[offset..] || [] if offset
          data = data[...limit] || [] if limit

          data
        end
        let(:expected_data) do
          defined?(super()) ? super() : matching_data
        end

        include_examples 'should order the results'

        describe 'with a block filter' do
          let(:filter) { -> { { 'author' => 'Ursula K. LeGuin' } } }
          let(:filtered_data) do
            super().select { |item| item['author'] == 'Ursula K. LeGuin' }
          end

          include_examples 'should order the results'
        end

        describe 'with a hash filter' do
          let(:filter) { { 'author' => 'Ursula K. LeGuin' } }
          let(:filtered_data) do
            super().select { |item| item['author'] == 'Ursula K. LeGuin' }
          end

          include_examples 'should order the results'
        end

        describe 'with a basic scope filter' do
          let(:filter) do
            Cuprum::Collections::Scope.new({ 'author' => 'Ursula K. LeGuin' })
          end
          let(:filtered_data) do
            super().select { |item| item['author'] == 'Ursula K. LeGuin' }
          end

          include_examples 'should order the results'
        end

        describe 'with a complex scope filter' do
          let(:filter) do
            Cuprum::Collections::Scope
              .new({ 'author' => 'Ursula K. LeGuin' })
              .or({ 'series' => nil })
          end
          let(:filtered_data) do
            super().select do |item|
              item['author'] == 'Ursula K. LeGuin' || item['series'].nil?
            end
          end

          include_examples 'should order the results'
        end
      end
    end
  end
end
