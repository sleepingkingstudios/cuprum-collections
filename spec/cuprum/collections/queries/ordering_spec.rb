# frozen_string_literal: true

require 'cuprum/collections/queries/ordering'

RSpec.describe Cuprum::Collections::Queries::Ordering do
  describe '::InvalidOrderError' do
    include_examples 'should define constant', :InvalidOrderError

    it { expect(described_class::InvalidOrderError).to be < ArgumentError }
  end

  describe '.normalize' do
    let(:error_message) do
      'order must be a list of attribute names and/or a hash of attribute ' \
        'names with values :asc or :desc'
    end

    it 'should define the class method' do
      expect(described_class)
        .to respond_to(:normalize)
        .with(0).arguments
        .and_unlimited_arguments
    end

    describe 'with no arguments' do
      let(:expected) { {} }

      it { expect(described_class.normalize).to be == expected }
    end

    describe 'with nil' do
      it 'should raise an exception' do
        expect { described_class.normalize nil }
          .to raise_error described_class::InvalidOrderError, error_message
      end
    end

    describe 'with an object' do
      it 'should raise an exception' do
        expect { described_class.normalize Object.new.freeze }
          .to raise_error described_class::InvalidOrderError, error_message
      end
    end

    describe 'with an empty string' do
      it 'should raise an exception' do
        expect { described_class.normalize '' }
          .to raise_error described_class::InvalidOrderError, error_message
      end
    end

    describe 'with an empty symbol' do
      it 'should raise an exception' do
        expect { described_class.normalize :'' }
          .to raise_error described_class::InvalidOrderError, error_message
      end
    end

    describe 'with an empty array' do
      let(:array)    { [] }
      let(:expected) { {} }

      it { expect(described_class.normalize array).to be == expected }
    end

    describe 'with an array with a nil item' do
      it 'should raise an exception' do
        expect { described_class.normalize [nil] }
          .to raise_error described_class::InvalidOrderError, error_message
      end
    end

    describe 'with an array with an object item' do
      it 'should raise an exception' do
        expect { described_class.normalize [Object.new.freeze] }
          .to raise_error described_class::InvalidOrderError, error_message
      end
    end

    describe 'with an array with an empty string item' do
      it 'should raise an exception' do
        expect { described_class.normalize [''] }
          .to raise_error described_class::InvalidOrderError, error_message
      end
    end

    describe 'with an array with an empty symbol item' do
      it 'should raise an exception' do
        expect { described_class.normalize [:''] }
          .to raise_error described_class::InvalidOrderError, error_message
      end
    end

    describe 'with an array with string items' do
      let(:attributes) { %w[title author series] }
      let(:expected)   { { title: :asc, author: :asc, series: :asc } }

      it { expect(described_class.normalize(attributes)).to be == expected }
    end

    describe 'with an array with symbol items' do
      let(:attributes) { %i[title author series] }
      let(:expected)   { { title: :asc, author: :asc, series: :asc } }

      it { expect(described_class.normalize(attributes)).to be == expected }
    end

    describe 'with an empty hash' do
      let(:hash)     { {} }
      let(:expected) { {} }

      it { expect(described_class.normalize(hash)).to be == expected }
    end

    describe 'with a hash with invalid keys' do
      it 'should raise an exception' do
        expect { described_class.normalize({ nil => :asc }) }
          .to raise_error described_class::InvalidOrderError, error_message
      end
    end

    describe 'with a hash with empty string keys' do
      it 'should raise an exception' do
        expect { described_class.normalize({ '' => :asc }) }
          .to raise_error described_class::InvalidOrderError, error_message
      end
    end

    describe 'with a hash with empty symbol keys' do
      it 'should raise an exception' do
        expect { described_class.normalize({ '': :asc }) }
          .to raise_error described_class::InvalidOrderError, error_message
      end
    end

    describe 'with a hash with nil value' do
      it 'should raise an exception' do
        expect { described_class.normalize({ title: nil }) }
          .to raise_error described_class::InvalidOrderError, error_message
      end
    end

    describe 'with a hash with object value' do
      it 'should raise an exception' do
        expect { described_class.normalize({ title: Object.new.freeze }) }
          .to raise_error described_class::InvalidOrderError, error_message
      end
    end

    describe 'with a hash with empty value' do
      it 'should raise an exception' do
        expect { described_class.normalize({ title: '' }) }
          .to raise_error described_class::InvalidOrderError, error_message
      end
    end

    describe 'with a hash with invalid value' do
      it 'should raise an exception' do
        expect { described_class.normalize({ title: 'wibbly' }) }
          .to raise_error described_class::InvalidOrderError, error_message
      end
    end

    describe 'with an attribute name as a string' do
      let(:attribute) { 'title' }
      let(:expected)  { { title: :asc } }

      it { expect(described_class.normalize attribute).to be == expected }
    end

    describe 'with an attribute name as a symbol' do
      let(:attribute) { :title }
      let(:expected)  { { title: :asc } }

      it { expect(described_class.normalize attribute).to be == expected }
    end

    describe 'with a list of attribute names as a string' do
      let(:attributes) { %w[title author series] }
      let(:expected)   { { title: :asc, author: :asc, series: :asc } }

      it { expect(described_class.normalize(*attributes)).to be == expected }
    end

    describe 'with a list of attribute names as a symbol' do
      let(:attributes) { %i[title author series] }
      let(:expected)   { { title: :asc, author: :asc, series: :asc } }

      it { expect(described_class.normalize(*attributes)).to be == expected }
    end

    describe 'with a hash with a string key' do
      let(:key)      { :asc }
      let(:hash)     { { 'title' => key } }
      let(:expected) { { title: :asc } }

      describe 'with key: :asc' do
        it { expect(described_class.normalize(hash)).to be == expected }
      end

      describe 'with key: "asc"' do
        let(:key) { 'asc' }

        it { expect(described_class.normalize(hash)).to be == expected }
      end

      describe 'with key: :ascending' do
        let(:key) { :ascending }

        it { expect(described_class.normalize(hash)).to be == expected }
      end

      describe 'with key: "ascending"' do
        let(:key) { 'ascending' }

        it { expect(described_class.normalize(hash)).to be == expected }
      end

      describe 'with key: :desc' do
        let(:key)      { :desc }
        let(:expected) { { title: :desc } }

        it { expect(described_class.normalize(hash)).to be == expected }
      end

      describe 'with key: "desc"' do
        let(:key)      { 'desc' }
        let(:expected) { { title: :desc } }

        it { expect(described_class.normalize(hash)).to be == expected }
      end

      describe 'with key: :descending' do
        let(:key)      { :descending }
        let(:expected) { { title: :desc } }

        it { expect(described_class.normalize(hash)).to be == expected }
      end

      describe 'with key: "descending"' do
        let(:key)      { 'descending' }
        let(:expected) { { title: :desc } }

        it { expect(described_class.normalize(hash)).to be == expected }
      end
    end

    describe 'with a hash with a symbol key' do
      let(:key)      { :asc }
      let(:hash)     { { title: key } }
      let(:expected) { { title: :asc } }

      describe 'with key: :asc' do
        it { expect(described_class.normalize(hash)).to be == expected }
      end

      describe 'with key: "asc"' do
        let(:key) { 'asc' }

        it { expect(described_class.normalize(hash)).to be == expected }
      end

      describe 'with key: :ascending' do
        let(:key) { :ascending }

        it { expect(described_class.normalize(hash)).to be == expected }
      end

      describe 'with key: "ascending"' do
        let(:key) { 'ascending' }

        it { expect(described_class.normalize(hash)).to be == expected }
      end

      describe 'with key: :desc' do
        let(:key)      { :desc }
        let(:expected) { { title: :desc } }

        it { expect(described_class.normalize(hash)).to be == expected }
      end

      describe 'with key: "desc"' do
        let(:key)      { 'desc' }
        let(:expected) { { title: :desc } }

        it { expect(described_class.normalize(hash)).to be == expected }
      end

      describe 'with key: :descending' do
        let(:key)      { :descending }
        let(:expected) { { title: :desc } }

        it { expect(described_class.normalize(hash)).to be == expected }
      end

      describe 'with key: "descending"' do
        let(:key)      { 'descending' }
        let(:expected) { { title: :desc } }

        it { expect(described_class.normalize(hash)).to be == expected }
      end
    end

    describe 'with a hash with string keys' do
      let(:hash) do
        { 'title' => :asc, 'author' => :desc, 'series' => :asc }
      end
      let(:expected) { { title: :asc, author: :desc, series: :asc } }

      it { expect(described_class.normalize(hash)).to be == expected }
    end

    describe 'with a hash with symbol keys' do
      let(:hash)     { { title: :asc, author: :desc, series: :asc } }
      let(:expected) { { title: :asc, author: :desc, series: :asc } }

      it { expect(described_class.normalize(hash)).to be == expected }
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

      it 'should normalize the ordering' do
        expect(described_class.normalize(*attributes, hash)).to be == expected
      end
    end
  end
end
