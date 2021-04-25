# frozen_string_literal: true

require 'cuprum/collections/query'
require 'cuprum/collections/query_builder'

RSpec.describe Cuprum::Collections::Query do
  subject(:query) { described_class.new }

  let(:described_class) { Spec::ExampleQuery }

  example_class 'Spec::ExampleQuery', Cuprum::Collections::Query do |klass| # rubocop:disable RSpec/DescribedClass
    klass.define_method(:query_builder) {}
    klass.define_method(:with_limit)    { |_count| }
    klass.define_method(:with_offset)   { |_count| }
    klass.define_method(:with_order)    { |*_args| }
  end

  describe '.new' do
    it { expect(described_class).to respond_to(:new).with(0).arguments }
  end

  describe '#criteria' do
    include_examples 'should define reader', :criteria, []

    it 'should not change the query criteria' do
      expect { query.criteria << ['censored', :eq, true] }
        .not_to change(query, :criteria)
    end
  end

  describe '#limit' do
    let(:copy) { described_class.new }

    before(:example) do
      allow(query).to receive(:dup).and_return(copy) # rubocop:disable RSpec/SubjectStub

      allow(copy).to receive(:with_limit)
    end

    it { expect(query).to respond_to(:limit).with(1).argument }

    it { expect(query.limit 3).to be copy }

    it 'should delegate to #with_limit' do
      query.limit 3

      expect(copy).to have_received(:with_limit).with(3)
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
  end

  describe '#offset' do
    let(:copy) { described_class.new }

    before(:example) do
      allow(query).to receive(:dup).and_return(copy) # rubocop:disable RSpec/SubjectStub

      allow(copy).to receive(:with_offset)
    end

    it { expect(query).to respond_to(:offset).with(1).argument }

    it { expect(query.offset 3).to be copy }

    it 'should delegate to #with_offset' do
      query.offset 3

      expect(copy).to have_received(:with_offset).with(3)
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
  end

  describe '#order' do
    let(:copy) { described_class.new }
    let(:error_class) do
      Cuprum::Collections::Queries::Ordering::InvalidOrderError
    end

    before(:example) do
      allow(query).to receive(:dup).and_return(copy) # rubocop:disable RSpec/SubjectStub

      allow(copy).to receive(:with_order)
    end

    it 'should define the method' do
      expect(query)
        .to respond_to(:order)
        .with(1).argument
        .and_unlimited_arguments
    end

    it { expect(query).to alias_method(:order).as(:order_by) }

    describe 'with nil' do
      let(:error_message) do
        'order must be a list of attribute names and/or a hash of attribute' \
        ' names with values :asc or :desc'
      end

      it 'should raise an exception' do
        expect { query.order nil }
          .to raise_error error_class, error_message
      end
    end

    describe 'with an object' do
      let(:error_message) do
        'order must be a list of attribute names and/or a hash of attribute' \
        ' names with values :asc or :desc'
      end

      it 'should raise an exception' do
        expect { query.order Object.new.freeze }
          .to raise_error error_class, error_message
      end
    end

    describe 'with an empty string' do
      let(:error_message) do
        'order must be a list of attribute names and/or a hash of attribute' \
        ' names with values :asc or :desc'
      end

      it 'should raise an exception' do
        expect { query.order '' }
          .to raise_error error_class, error_message
      end
    end

    describe 'with an empty symbol' do
      let(:error_message) do
        'order must be a list of attribute names and/or a hash of attribute' \
        ' names with values :asc or :desc'
      end

      it 'should raise an exception' do
        expect { query.order :'' }
          .to raise_error error_class, error_message
      end
    end

    describe 'with an empty hash' do
      let(:error_message) do
        'order must be a list of attribute names and/or a hash of attribute' \
        ' names with values :asc or :desc'
      end

      it 'should raise an exception' do
        expect { query.order({}) }
          .to raise_error error_class, error_message
      end
    end

    describe 'with a hash with invalid keys' do
      let(:error_message) do
        'order must be a list of attribute names and/or a hash of attribute' \
        ' names with values :asc or :desc'
      end

      it 'should raise an exception' do
        expect { query.order({ nil => :asc }) }
          .to raise_error error_class, error_message
      end
    end

    describe 'with a hash with empty string keys' do
      let(:error_message) do
        'order must be a list of attribute names and/or a hash of attribute' \
        ' names with values :asc or :desc'
      end

      it 'should raise an exception' do
        expect { query.order({ '' => :asc }) }
          .to raise_error error_class, error_message
      end
    end

    describe 'with a hash with empty symbol keys' do
      let(:error_message) do
        'order must be a list of attribute names and/or a hash of attribute' \
        ' names with values :asc or :desc'
      end

      it 'should raise an exception' do
        expect { query.order({ '': :asc }) }
          .to raise_error error_class, error_message
      end
    end

    describe 'with a hash with nil value' do
      let(:error_message) do
        'order must be a list of attribute names and/or a hash of attribute' \
        ' names with values :asc or :desc'
      end

      it 'should raise an exception' do
        expect { query.order({ title: nil }) }
          .to raise_error error_class, error_message
      end
    end

    describe 'with a hash with object value' do
      let(:error_message) do
        'order must be a list of attribute names and/or a hash of attribute' \
        ' names with values :asc or :desc'
      end

      it 'should raise an exception' do
        expect { query.order({ title: Object.new.freeze }) }
          .to raise_error error_class, error_message
      end
    end

    describe 'with a hash with empty value' do
      let(:error_message) do
        'order must be a list of attribute names and/or a hash of attribute' \
        ' names with values :asc or :desc'
      end

      it 'should raise an exception' do
        expect { query.order({ title: '' }) }
          .to raise_error error_class, error_message
      end
    end

    describe 'with a hash with invalid value' do
      let(:error_message) do
        'order must be a list of attribute names and/or a hash of attribute' \
        ' names with values :asc or :desc'
      end

      it 'should raise an exception' do
        expect { query.order({ title: 'wibbly' }) }
          .to raise_error error_class, error_message
      end
    end

    describe 'with an attribute name as a string' do
      let(:attribute) { 'title' }
      let(:expected)  { { title: :asc } }

      it { expect(query.order attribute).to be copy }

      it 'should delegate to #with_offset' do
        query.order(attribute)

        expect(copy).to have_received(:with_order).with(expected)
      end
    end

    describe 'with an attribute name as a symbol' do
      let(:attribute) { :title }
      let(:expected)  { { title: :asc } }

      it { expect(query.order attribute).to be copy }

      it 'should delegate to #with_offset' do
        query.order(attribute)

        expect(copy).to have_received(:with_order).with(expected)
      end
    end

    describe 'with a list of attribute names as a string' do
      let(:attributes) { %w[title author series] }
      let(:expected)   { { title: :asc, author: :asc, series: :asc } }

      it { expect(query.order(*attributes)).to be copy }

      it 'should delegate to #with_offset' do
        query.order(*attributes)

        expect(copy).to have_received(:with_order).with(expected)
      end
    end

    describe 'with a list of attribute names as a symbol' do
      let(:attributes) { %i[title author series] }
      let(:expected)   { { title: :asc, author: :asc, series: :asc } }

      it { expect(query.order(*attributes)).to be copy }

      it 'should delegate to #with_offset' do
        query.order(*attributes)

        expect(copy).to have_received(:with_order).with(expected)
      end
    end

    describe 'with a hash with a string key' do
      let(:key)      { :asc }
      let(:hash)     { { 'title' => key } }
      let(:expected) { { title: :asc } }

      it { expect(query.order hash).to be copy }

      describe 'with key: :asc' do
        it 'should delegate to #with_offset' do
          query.order(hash)

          expect(copy).to have_received(:with_order).with(expected)
        end
      end

      describe 'with key: "asc"' do
        let(:key) { 'asc' }

        it 'should delegate to #with_offset' do
          query.order(hash)

          expect(copy).to have_received(:with_order).with(expected)
        end
      end

      describe 'with key: :ascending' do
        let(:key) { :ascending }

        it 'should delegate to #with_offset' do
          query.order(hash)

          expect(copy).to have_received(:with_order).with(expected)
        end
      end

      describe 'with key: "ascending"' do
        let(:key) { 'ascending' }

        it 'should delegate to #with_offset' do
          query.order(hash)

          expect(copy).to have_received(:with_order).with(expected)
        end
      end

      describe 'with key: :desc' do
        let(:key)      { :desc }
        let(:expected) { { title: :desc } }

        it 'should delegate to #with_offset' do
          query.order(hash)

          expect(copy).to have_received(:with_order).with(expected)
        end
      end

      describe 'with key: "desc"' do
        let(:key)      { 'desc' }
        let(:expected) { { title: :desc } }

        it 'should delegate to #with_offset' do
          query.order(hash)

          expect(copy).to have_received(:with_order).with(expected)
        end
      end

      describe 'with key: :descending' do
        let(:key)      { :descending }
        let(:expected) { { title: :desc } }

        it 'should delegate to #with_offset' do
          query.order(hash)

          expect(copy).to have_received(:with_order).with(expected)
        end
      end

      describe 'with key: "descending"' do
        let(:key)      { 'descending' }
        let(:expected) { { title: :desc } }

        it 'should delegate to #with_offset' do
          query.order(hash)

          expect(copy).to have_received(:with_order).with(expected)
        end
      end
    end

    describe 'with a hash with a symbol key' do
      let(:key)      { :asc }
      let(:hash)     { { title: key } }
      let(:expected) { { title: :asc } }

      it { expect(query.order hash).to be copy }

      describe 'with key: :asc' do
        it 'should delegate to #with_offset' do
          query.order(hash)

          expect(copy).to have_received(:with_order).with(expected)
        end
      end

      describe 'with key: "asc"' do
        let(:key) { 'asc' }

        it 'should delegate to #with_offset' do
          query.order(hash)

          expect(copy).to have_received(:with_order).with(expected)
        end
      end

      describe 'with key: :ascending' do
        let(:key) { :ascending }

        it 'should delegate to #with_offset' do
          query.order(hash)

          expect(copy).to have_received(:with_order).with(expected)
        end
      end

      describe 'with key: "ascending"' do
        let(:key) { 'ascending' }

        it 'should delegate to #with_offset' do
          query.order(hash)

          expect(copy).to have_received(:with_order).with(expected)
        end
      end

      describe 'with key: :desc' do
        let(:key)      { :desc }
        let(:expected) { { title: :desc } }

        it 'should delegate to #with_offset' do
          query.order(hash)

          expect(copy).to have_received(:with_order).with(expected)
        end
      end

      describe 'with key: "desc"' do
        let(:key)      { 'desc' }
        let(:expected) { { title: :desc } }

        it 'should delegate to #with_offset' do
          query.order(hash)

          expect(copy).to have_received(:with_order).with(expected)
        end
      end

      describe 'with key: :descending' do
        let(:key)      { :descending }
        let(:expected) { { title: :desc } }

        it 'should delegate to #with_offset' do
          query.order(hash)

          expect(copy).to have_received(:with_order).with(expected)
        end
      end

      describe 'with key: "descending"' do
        let(:key)      { 'descending' }
        let(:expected) { { title: :desc } }

        it 'should delegate to #with_offset' do
          query.order(hash)

          expect(copy).to have_received(:with_order).with(expected)
        end
      end
    end

    describe 'with a hash with string keys' do
      let(:hash) do
        { 'title' => :asc, 'author' => :desc, 'series' => :asc }
      end
      let(:expected) { { title: :asc, author: :desc, series: :asc } }

      it { expect(query.order hash).to be copy }

      it 'should delegate to #with_offset' do
        query.order(hash)

        expect(copy).to have_received(:with_order).with(expected)
      end
    end

    describe 'with a hash with symbol keys' do
      let(:hash)     { { title: :asc, author: :desc, series: :asc } }
      let(:expected) { { title: :asc, author: :desc, series: :asc } }

      it { expect(query.order hash).to be copy }

      it 'should delegate to #with_offset' do
        query.order(hash)

        expect(copy).to have_received(:with_order).with(expected)
      end
    end

    describe 'with a list of attribute names and a hash' do
      let(:attributes) { %i[publisher page_count] }
      let(:hash)       { { title: :asc, author: :desc, series: :asc } }
      let(:expected) do
        {
          publisher:  :asc,
          page_count: :asc,
          title:      :asc,
          author:     :desc,
          series:     :asc
        }
      end

      it { expect(query.order hash).to be copy }

      it 'should delegate to #with_offset' do
        query.order(*attributes, hash)

        expect(copy).to have_received(:with_order).with(expected)
      end
    end
  end

  describe '#where' do
    let(:other) { described_class.new }
    let(:builder) do
      instance_double(Cuprum::Collections::QueryBuilder, call: other)
    end

    before(:example) do
      allow(query).to receive(:query_builder).and_return(builder) # rubocop:disable RSpec/SubjectStub
    end

    it 'should define the method' do
      expect(query)
        .to respond_to(:where)
        .with(0..1).arguments
        .and_keywords(:strategy)
        .and_a_block
    end

    describe 'with a specified strategy' do
      let(:strategy) { :random }

      it { expect(query.where(strategy: strategy)).to be other }

      it 'should delegate to the query builder' do
        query.where(strategy: strategy)

        expect(builder)
          .to have_received(:call)
          .with(strategy: strategy, where: nil)
      end
    end

    describe 'with no parameters' do
      it { expect(query.where).to be_a described_class }

      it { expect(query.where).not_to be query }

      it 'should not delegate to the query builder' do
        query.where

        expect(builder).not_to have_received(:call)
      end
    end

    describe 'with a block' do
      let(:block) { -> { { title: 'The Caves of Steel' } } }

      it { expect(query.where(&block)).to be other }

      it 'should delegate to the query builder' do
        query.where(&block)

        expect(builder)
          .to have_received(:call)
          .with(strategy: nil, where: block)
      end
    end

    describe 'with criteria and strategy: :unsafe' do
      let(:criteria) do
        [
          ['title',  :eq, 'The Caves of Steel'],
          ['author', :eq, 'Isaac Asimov']
        ]
      end

      it 'should delegate to the query builder' do
        query.where(criteria, strategy: :unsafe)

        expect(builder)
          .to have_received(:call)
          .with(strategy: :unsafe, where: criteria)
      end
    end
  end

  describe '#with_criteria' do
    let(:criteria) do
      [
        ['title',  :eq, 'The Caves of Steel'],
        ['author', :eq, 'Isaac Asimov']
      ]
    end
    let(:expected) { criteria }

    it { expect(query).to respond_to(:with_criteria, true).with(1).argument }

    it { expect(query.send(:with_criteria, criteria)).to be query }

    it 'should append the criteria' do
      expect { query.send(:with_criteria, criteria) }
        .to change(query, :criteria)
        .to be == expected
    end

    context 'when the query has criteria' do
      let(:old_criteria) do
        [
          ['genre', :eg, 'Science Fiction']
        ]
      end
      let(:expected) { old_criteria + criteria }

      before(:example) do
        query.send(:with_criteria, old_criteria)
      end

      it 'should append the criteria' do
        expect { query.send(:with_criteria, criteria) }
          .to change(query, :criteria)
          .to be == expected
      end
    end
  end
end
