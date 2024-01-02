# frozen_string_literal: true

require 'cuprum/collections/basic/scopes/base'
require 'cuprum/collections/rspec/fixtures'

RSpec.describe Cuprum::Collections::Basic::Scopes::Base do
  subject(:scope) { described_class.new }

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_any_keywords
    end
  end

  describe '#call' do
    let(:data) { [] }

    it 'should define the method' do
      expect(scope).to respond_to(:call).with(0).arguments.and_keywords(:data)
    end

    describe 'with nil' do
      let(:error_message) { 'data must be an Array' }

      it 'should raise an exception' do
        expect { scope.call(data: nil) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with an Object' do
      let(:error_message) { 'data must be an Array' }

      it 'should raise an exception' do
        expect { scope.call(data: Object.new.freeze) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with an empty Array' do
      let(:data) { [] }

      it { expect(scope.call(data: data)).to be == data }
    end

    describe 'with data' do
      let(:data) do
        Cuprum::Collections::RSpec::Fixtures::BOOKS_FIXTURES
      end

      it { expect(scope.call(data: data)).to be == data }
    end
  end

  describe '#match?' do
    let(:item) { [] }

    it 'should define the method' do
      expect(scope).to respond_to(:match?).with(0).arguments.and_keywords(:item)
    end

    it 'should alias the method' do
      expect(scope).to have_aliased_method(:match?).as(:matches?)
    end

    describe 'with nil' do
      let(:error_message) { 'item must be a Hash' }

      it 'should raise an exception' do
        expect { scope.match?(item: nil) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with an Object' do
      let(:error_message) { 'item must be a Hash' }

      it 'should raise an exception' do
        expect { scope.match?(item: Object.new.freeze) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with an item' do
      let(:item) do
        Cuprum::Collections::RSpec::Fixtures::BOOKS_FIXTURES
          .find { |book| book['title'] == 'The Silmarillion' }
      end

      it { expect(scope.match?(item: item)).to be true }
    end
  end

  context 'with a scope subclass' do
    let(:described_class) { Spec::HasSeriesScope }

    # rubocop:disable RSpec/DescribedClass
    example_class 'Spec::HasSeriesScope',
      Cuprum::Collections::Basic::Scopes::Base \
    do |klass|
      klass.define_method :match? do |item:|
        !(item['series'].nil? || item['series'].empty?)
      end
    end
    # rubocop:enable RSpec/DescribedClass

    describe '#call' do
      describe 'with an empty Array' do
        let(:data) { [] }

        it { expect(scope.call(data: data)).to be == data }
      end

      describe 'with data' do
        let(:data) do
          Cuprum::Collections::RSpec::Fixtures::BOOKS_FIXTURES
        end
        let(:expected) do
          data.reject do |item|
            item['series'].nil?
          end
        end

        it { expect(scope.call(data: data)).to be == expected }
      end
    end
  end
end
