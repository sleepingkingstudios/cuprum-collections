# frozen_string_literal: true

require 'cuprum/collections/rspec'
require 'cuprum/collections/rspec/fixtures'

module Cuprum::Collections::RSpec
  OPERATORS = %i[eq ne].freeze
  private_constant :OPERATORS

  # Contract validating the behavior of a Query implementation.
  QUERY_CONTRACT = lambda do |operators: OPERATORS|
    operators = Set.new(operators.map(&:to_sym))

    shared_context 'when the query has limit: value' do
      let(:limit)         { 3 }
      let(:query)         { super().limit(limit) }
      let(:matching_data) { super()[0...limit] }
    end

    shared_context 'when the query has limit: value and offset: value' do
      let(:limit)         { 3 }
      let(:offset)        { 2 }
      let(:query)         { super().limit(limit).offset(offset) }
      let(:matching_data) { super()[offset...(offset + limit)] || [] }
    end

    shared_context 'when the query has offset: value' do
      let(:offset)        { 2 }
      let(:query)         { super().offset(offset) }
      let(:matching_data) { super()[offset..-1] || [] }
    end

    shared_context 'when the query has order: a simple ordering' do
      let(:query)         { super().order(:title) }
      let(:matching_data) { super().sort_by { |item| item['title'] } }
    end

    shared_context 'when the query has order: a complex ordering' do
      let(:order) do
        {
          author: :asc,
          title:  :desc
        }
      end
      let(:query) { super().order(order) }
      let(:matching_data) do
        super().sort do |u, v|
          cmp = u['author'] <=> v['author']

          cmp.zero? ? (v['title'] <=> u['title']) : cmp
        end
      end
    end

    shared_context 'when the query has where: a simple filter' do
      let(:query) do
        super().where do
          { author: 'Ursula K. LeGuin' }
        end
      end
      let(:matching_data) do
        super().select { |item| item['author'] == 'Ursula K. LeGuin' }
      end
    end

    shared_context 'when the query has where: a complex filter' do
      let(:query) do
        super().where do
          {
            author: equals('Ursula K. LeGuin'),
            series: not_equal('Earthsea')
          }
        end
      end
      let(:matching_data) do
        super()
          .select { |item| item['author'] == 'Ursula K. LeGuin' }
          .reject { |item| item['series'] == 'Earthsea' }
      end
    end

    shared_context 'when the query has composed filters' do
      let(:query) do
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

    shared_context 'when the query has an equals filter' do
      let(:query) do
        super().where { { author: equals('Ursula K. LeGuin') } }
      end
      let(:matching_data) do
        super().select { |item| item['author'] == 'Ursula K. LeGuin' }
      end
    end

    shared_context 'when the query has a not_equal filter' do
      let(:query) do
        super().where { { author: not_equal('Ursula K. LeGuin') } }
      end
      let(:matching_data) do
        super().reject { |item| item['author'] == 'Ursula K. LeGuin' }
      end
    end

    shared_context 'when the query has multiple chained query methods' do
      let(:query) do
        super()
          .where { { author: 'Ursula K. LeGuin' } }
          .order(title: :desc)
          .limit(2)
          .offset(1)
      end
      let(:matching_data) do
        super()
          .select { |item| item['author'] == 'Ursula K. LeGuin' }
          .sort { |u, v| v['title'] <=> u['title'] }
          .slice(1, 2) || []
      end
    end

    it 'should be enumerable' do
      expect(described_class).to be < Enumerable
    end

    describe '#criteria' do
      include_examples 'should have reader', :criteria, []

      wrap_context 'when the query has where: a simple filter' do
        let(:expected) { [['author', :eq, 'Ursula K. LeGuin']] }

        it { expect(query.criteria).to be == expected }
      end

      wrap_context 'when the query has where: a complex filter' do
        let(:expected) do
          [
            ['author', :eq, 'Ursula K. LeGuin'],
            ['series', :ne, 'Earthsea']
          ]
        end

        it { expect(query.criteria).to be == expected }
      end

      wrap_context 'when the query has composed filters' do
        let(:expected) do
          [
            ['author', :eq, 'Ursula K. LeGuin'],
            ['series', :ne, 'Earthsea']
          ]
        end

        it { expect(query.criteria).to be == expected }
      end

      if operators.include?(:eq)
        wrap_context 'when the query has an equals filter' do
          let(:expected) { [['author', :eq, 'Ursula K. LeGuin']] }

          it { expect(query.criteria).to be == expected }
        end
      end

      if operators.include?(:ne)
        wrap_context 'when the query has a not_equal filter' do
          let(:expected) { [['author', :ne, 'Ursula K. LeGuin']] }

          it { expect(query.criteria).to be == expected }
        end
      end
    end

    describe '#each' do
      shared_examples 'should enumerate the matching data' do
        describe 'with no arguments' do
          it { expect(query.each).to be_a Enumerator }

          it { expect(query.each.count).to be == matching_data.size }

          it { expect(query.each.to_a).to deep_match expected_data }
        end

        describe 'with a block' do
          it 'should yield each matching item' do
            expect { |block| query.each(&block) }
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

      wrap_context 'when the query has limit: value' do
        include_examples 'should enumerate the matching data'
      end

      wrap_context 'when the query has limit: value and offset: value' do
        include_examples 'should enumerate the matching data'
      end

      wrap_context 'when the query has offset: value' do
        include_examples 'should enumerate the matching data'
      end

      wrap_context 'when the query has order: a simple ordering' do
        include_examples 'should enumerate the matching data'
      end

      wrap_context 'when the query has order: a complex ordering' do
        include_examples 'should enumerate the matching data'
      end

      wrap_context 'when the query has where: a simple filter' do
        include_examples 'should enumerate the matching data'
      end

      wrap_context 'when the query has multiple chained query methods' do
        include_examples 'should enumerate the matching data'
      end

      context 'when the collection has many items' do
        let(:data) { BOOKS_FIXTURES }

        include_examples 'should enumerate the matching data'

        wrap_context 'when the query has limit: value' do
          include_examples 'should enumerate the matching data'
        end

        wrap_context 'when the query has limit: value and offset: value' do
          include_examples 'should enumerate the matching data'
        end

        wrap_context 'when the query has offset: value' do
          include_examples 'should enumerate the matching data'
        end

        wrap_context 'when the query has order: a simple ordering' do
          include_examples 'should enumerate the matching data'
        end

        wrap_context 'when the query has order: a complex ordering' do
          include_examples 'should enumerate the matching data'
        end

        wrap_context 'when the query has where: a simple filter' do
          include_examples 'should enumerate the matching data'
        end

        wrap_context 'when the query has where: a complex filter' do
          include_examples 'should enumerate the matching data'
        end

        wrap_context 'when the query has composed filters' do
          include_examples 'should enumerate the matching data'
        end

        wrap_context 'when the query has an equals filter' do
          include_examples 'should enumerate the matching data'
        end

        if operators.include?(:eq)
          wrap_context 'when the query has a not_equal filter' do
            include_examples 'should enumerate the matching data'
          end
        end

        if operators.include?(:ne)
          wrap_context 'when the query has multiple chained query methods' do
            include_examples 'should enumerate the matching data'
          end
        end
      end
    end

    describe '#limit' do
      let(:count) { 3 }

      it { expect(query).to respond_to(:limit).with(1).argument }

      it { expect(query.limit 3).to be_a described_class }

      it { expect(query.limit 3).not_to be query }

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
    end

    describe '#offset' do
      let(:count) { 3 }

      it { expect(query).to respond_to(:offset).with(1).argument }

      it { expect(query.offset 3).to be_a described_class }

      it { expect(query.offset 3).not_to be query }

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
    end

    describe '#order' do
      it 'should define the method' do
        expect(query)
          .to respond_to(:order)
          .with(1).argument
          .and_unlimited_arguments
      end

      it { expect(query).to alias_method(:order).as(:order_by) }

      it { expect(query.order :title).to be_a described_class }

      it { expect(query.order :title).not_to be query }

      describe 'with a hash with invalid keys' do
        let(:error_message) do
          'order must be a list of attribute names and/or a hash of attribute' \
          ' names with values :asc or :desc'
        end

        it 'should raise an exception' do
          expect { query.order({ nil => :asc }) }
            .to raise_error ArgumentError, error_message
        end
      end

      describe 'with a hash with empty string keys' do
        let(:error_message) do
          'order must be a list of attribute names and/or a hash of attribute' \
          ' names with values :asc or :desc'
        end

        it 'should raise an exception' do
          expect { query.order({ '' => :asc }) }
            .to raise_error ArgumentError, error_message
        end
      end

      describe 'with a hash with empty symbol keys' do
        let(:error_message) do
          'order must be a list of attribute names and/or a hash of attribute' \
          ' names with values :asc or :desc'
        end

        it 'should raise an exception' do
          expect { query.order({ '': :asc }) }
            .to raise_error ArgumentError, error_message
        end
      end

      describe 'with a hash with nil value' do
        let(:error_message) do
          'order must be a list of attribute names and/or a hash of attribute' \
          ' names with values :asc or :desc'
        end

        it 'should raise an exception' do
          expect { query.order({ title: nil }) }
            .to raise_error ArgumentError, error_message
        end
      end

      describe 'with a hash with object value' do
        let(:error_message) do
          'order must be a list of attribute names and/or a hash of attribute' \
          ' names with values :asc or :desc'
        end

        it 'should raise an exception' do
          expect { query.order({ title: Object.new.freeze }) }
            .to raise_error ArgumentError, error_message
        end
      end

      describe 'with a hash with empty value' do
        let(:error_message) do
          'order must be a list of attribute names and/or a hash of attribute' \
          ' names with values :asc or :desc'
        end

        it 'should raise an exception' do
          expect { query.order({ title: '' }) }
            .to raise_error ArgumentError, error_message
        end
      end

      describe 'with a hash with invalid value' do
        let(:error_message) do
          'order must be a list of attribute names and/or a hash of attribute' \
          ' names with values :asc or :desc'
        end

        it 'should raise an exception' do
          expect { query.order({ title: 'wibbly' }) }
            .to raise_error ArgumentError, error_message
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

      wrap_context 'when the query has limit: value' do
        it { expect(query.to_a).to deep_match expected_data }
      end

      wrap_context 'when the query has limit: value and offset: value' do
        it { expect(query.to_a).to deep_match expected_data }
      end

      wrap_context 'when the query has offset: value' do
        it { expect(query.to_a).to deep_match expected_data }
      end

      wrap_context 'when the query has order: a simple ordering' do
        it { expect(query.to_a).to deep_match expected_data }
      end

      wrap_context 'when the query has order: a complex ordering' do
        it { expect(query.to_a).to deep_match expected_data }
      end

      wrap_context 'when the query has where: a simple filter' do
        it { expect(query.to_a).to deep_match expected_data }
      end

      wrap_context 'when the query has multiple chained query methods' do
        it { expect(query.to_a).to deep_match expected_data }
      end

      context 'when the collection has many items' do
        let(:data) { BOOKS_FIXTURES }

        it { expect(query.to_a).to deep_match expected_data }

        wrap_context 'when the query has limit: value' do
          it { expect(query.to_a).to deep_match expected_data }
        end

        wrap_context 'when the query has limit: value and offset: value' do
          it { expect(query.to_a).to deep_match expected_data }
        end

        wrap_context 'when the query has offset: value' do
          it { expect(query.to_a).to deep_match expected_data }
        end

        wrap_context 'when the query has order: a simple ordering' do
          it { expect(query.to_a).to deep_match expected_data }
        end

        wrap_context 'when the query has order: a complex ordering' do
          it { expect(query.to_a).to deep_match expected_data }
        end

        wrap_context 'when the query has where: a simple filter' do
          it { expect(query.to_a).to deep_match expected_data }
        end

        wrap_context 'when the query has where: a complex filter' do
          it { expect(query.to_a).to deep_match expected_data }
        end

        wrap_context 'when the query has composed filters' do
          it { expect(query.to_a).to deep_match expected_data }
        end

        if operators.include?(:eq)
          wrap_context 'when the query has an equals filter' do
            it { expect(query.to_a).to deep_match expected_data }
          end
        end

        if operators.include?(:ne)
          wrap_context 'when the query has a not_equal filter' do
            it { expect(query.to_a).to deep_match expected_data }
          end
        end

        wrap_context 'when the query has multiple chained query methods' do
          it { expect(query.to_a).to deep_match expected_data }
        end
      end
    end

    describe '#where' do
      let(:block) { -> { { title: 'The Caves of Steel' } } }

      it { expect(query).to respond_to(:where).with(0).arguments.and_a_block }

      it { expect(query.where(&block)).to be_a described_class }

      it { expect(query.where(&block)).not_to be query }
    end
  end
end
