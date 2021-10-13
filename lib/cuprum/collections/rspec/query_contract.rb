# frozen_string_literal: true

require 'cuprum/collections/rspec'
require 'cuprum/collections/rspec/fixtures'
require 'cuprum/collections/rspec/querying_contract'

module Cuprum::Collections::RSpec # rubocop:disable Style/Documentation
  default_operators = Cuprum::Collections::Queries::Operators.values

  # Contract validating the behavior of a Query implementation.
  QUERY_CONTRACT = lambda do |operators: default_operators.freeze|
    operators = Set.new(operators.map(&:to_sym))

    include_contract Cuprum::Collections::RSpec::QUERYING_CONTEXTS

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
      # :nocov:
      scoped =
        if filter.is_a?(Proc)
          query.where(&filter)
        elsif !filter.nil?
          query.where(filter)
        else
          query
        end
      # :nocov:
      scoped = scoped.limit(limit)   if limit
      scoped = scoped.offset(offset) if offset
      scoped = scoped.order(order)   if order

      scoped
    end

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

      it { expect(query.count).to be == expected_data.count }

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

    describe '#criteria' do
      include_examples 'should have reader', :criteria, []

      wrap_context 'when the query has where: a simple block filter' do
        let(:expected) { [['author', :equal, 'Ursula K. LeGuin']] }

        it { expect(scoped_query.criteria).to be == expected }
      end

      wrap_context 'when the query has where: a complex block filter' do
        let(:expected) do
          [
            ['author', :equal,     'Ursula K. LeGuin'],
            ['series', :not_equal, 'Earthsea']
          ]
        end

        if operators.include?(OPERATORS::EQUAL) &&
           operators.include?(OPERATORS::NOT_EQUAL)
          it { expect(scoped_query.criteria).to be == expected }
        else
          # :nocov:
          pending
          # :nocov:
        end
      end

      wrap_context 'when the query has composed filters' do
        let(:expected) do
          [
            ['author', :equal,     'Ursula K. LeGuin'],
            ['series', :not_equal, 'Earthsea']
          ]
        end

        it { expect(scoped_query.criteria).to be == expected }
      end

      wrap_context 'when the query has where: an equal block filter' do
        let(:expected) { [['author', :equal, 'Ursula K. LeGuin']] }

        if operators.include?(OPERATORS::EQUAL)
          it { expect(scoped_query.criteria).to be == expected }
        else
          # :nocov:
          pending
          # :nocov:
        end
      end

      wrap_context 'when the query has where: a not_equal block filter' do
        let(:expected) { [['author', :not_equal, 'Ursula K. LeGuin']] }

        if operators.include?(OPERATORS::NOT_EQUAL)
          it { expect(scoped_query.criteria).to be == expected }
        else
          # :nocov:
          pending
          # :nocov:
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

      it { expect(query).to respond_to(:each).with(0).arguments }

      include_examples 'should enumerate the matching data'

      include_contract Cuprum::Collections::RSpec::QUERYING_CONTRACT,
        block:     lambda {
          include_examples 'should enumerate the matching data'
        },
        operators: operators

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

        include_contract Cuprum::Collections::RSpec::QUERYING_CONTRACT,
          block:     lambda {
            include_examples 'should enumerate the matching data'
          },
          operators: operators

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

      include_examples 'should define predicate', :exists?

      include_examples 'should check the existence of matching data'

      include_contract Cuprum::Collections::RSpec::QUERYING_CONTRACT,
        block:     lambda {
          include_examples 'should check the existence of matching data'
        },
        operators: operators

      wrap_context 'when the query has composed filters' do
        include_examples 'should check the existence of matching data'
      end

      context 'when the collection has many items' do
        let(:data) { BOOKS_FIXTURES }

        include_examples 'should check the existence of matching data'

        include_contract Cuprum::Collections::RSpec::QUERYING_CONTRACT,
          block:     lambda {
            include_examples 'should check the existence of matching data'
          },
          operators: operators

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
        it { expect(query.limit 0).to be_a described_class }

        it { expect(query.limit 0).not_to be query }

        it { expect(query.limit(0).limit).to be 0 }
      end

      describe 'with a positive integer' do
        it { expect(query.limit 3).to be_a described_class }

        it { expect(query.limit 3).not_to be query }

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
        it { expect(query.offset 0).to be_a described_class }

        it { expect(query.offset 0).not_to be query }

        it { expect(query.offset(0).offset).to be 0 }
      end

      describe 'with a positive integer' do
        it { expect(query.offset 3).to be_a described_class }

        it { expect(query.offset 3).not_to be query }

        it { expect(query.offset(3).offset).to be 3 }
      end
    end

    describe '#order' do
      let(:default_order) { defined?(super()) ? super() : {} }
      let(:error_message) do
        'order must be a list of attribute names and/or a hash of attribute' \
          ' names with values :asc or :desc'
      end

      it 'should define the method' do
        expect(query)
          .to respond_to(:order)
          .with(0).arguments
          .and_unlimited_arguments
      end

      it { expect(query).to alias_method(:order).as(:order_by) }

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

        it { expect(query.order :title).to be_a described_class }

        it { expect(query.order :title).not_to be query }

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

    describe '#to_a' do
      let(:data)          { [] }
      let(:matching_data) { data }
      let(:expected_data) do
        defined?(super()) ? super() : matching_data
      end

      it { expect(query).to respond_to(:to_a).with(0).arguments }

      it { expect(query.to_a).to deep_match expected_data }

      include_contract Cuprum::Collections::RSpec::QUERYING_CONTRACT,
        block:     lambda {
          it { expect(scoped_query.to_a).to deep_match expected_data }
        },
        operators: operators

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

        include_contract Cuprum::Collections::RSpec::QUERYING_CONTRACT,
          block:     lambda {
            it { expect(scoped_query.to_a).to deep_match expected_data }
          },
          operators: operators

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
      let(:block) { -> { { title: 'The Caves of Steel' } } }

      it 'should define the method' do
        expect(query)
          .to respond_to(:where)
          .with(0..1).arguments
          .and_keywords(:strategy)
          .and_a_block
      end

      describe 'with no arguments' do
        it { expect(query.where).to be_a described_class }

        it { expect(query.where).not_to be query }
      end

      describe 'with a block' do
        it { expect(query.where(&block)).to be_a described_class }

        it { expect(query.where(&block)).not_to be query }
      end

      describe 'with a valid strategy' do
        it 'should return a query instance' do
          expect(query.where(strategy: :block, &block)).to be_a described_class
        end

        it { expect(query.where(strategy: :block, &block)).not_to be query }
      end

      describe 'with parameters that do not match a strategy' do
        let(:error_class)   { Cuprum::Collections::QueryBuilder::ParseError }
        let(:error_message) { 'unable to parse query with strategy nil' }

        it 'should raise an exception' do
          expect { query.where(%w[ichi ni san]) }
            .to raise_error error_class, error_message
        end
      end

      describe 'with an invalid strategy' do
        let(:error_class)   { Cuprum::Collections::QueryBuilder::ParseError }
        let(:error_message) { 'unable to parse query with strategy :random' }

        it 'should raise an exception' do
          expect { query.where(strategy: :random) }
            .to raise_error error_class, error_message
        end
      end

      describe 'with invalid parameters for a strategy' do
        let(:error_class)   { Cuprum::Collections::QueryBuilder::ParseError }
        let(:error_message) { 'unable to parse query with strategy :block' }

        it 'should raise an exception' do
          expect { query.where(strategy: :block) }
            .to raise_error error_class, error_message
        end
      end
    end
  end
end
