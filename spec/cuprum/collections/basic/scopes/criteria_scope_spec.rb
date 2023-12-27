# frozen_string_literal: true

require 'cuprum/collections/basic/scopes/criteria_scope'
require 'cuprum/collections/rspec/contracts/scope_contracts'

RSpec.describe Cuprum::Collections::Basic::Scopes::CriteriaScope do
  include Cuprum::Collections::RSpec::Contracts::ScopeContracts

  subject(:scope) { described_class.new(criteria: criteria) }

  let(:criteria) { [] }

  include_contract 'should be a criteria scope'

  describe '#call' do
    let(:data) { [] }

    def filtered_data
      scope.call(data: data)
    end

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

    include_contract 'should filter data by criteria'
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

    context 'when the scope has no criteria' do
      let(:criteria) { [] }

      describe 'with an item' do
        let(:item) do
          Cuprum::Collections::RSpec::Fixtures::BOOKS_FIXTURES
            .find { |book| book['title'] == 'The Silmarillion' }
        end

        it { expect(scope.match?(item: item)).to be true }
      end
    end

    context 'when the scope has an equality criterion' do
      let(:criteria) do
        described_class.parse({ 'title' => 'The Word for World is Forest' })
      end

      describe 'with a non-matching item' do
        let(:item) do
          Cuprum::Collections::RSpec::Fixtures::BOOKS_FIXTURES
            .find { |book| book['title'] == 'The Silmarillion' }
        end

        it { expect(scope.match?(item: item)).to be false }
      end

      describe 'with a matching item' do
        let(:item) do
          Cuprum::Collections::RSpec::Fixtures::BOOKS_FIXTURES
            .find do |book|
              book['title'] == 'The Word for World is Forest'
            end
        end

        it { expect(scope.match?(item: item)).to be true }
      end
    end

    context 'when the scope has a greater than criterion' do
      let(:criteria) do
        described_class.parse do
          { 'published_at' => greater_than('1972-03-13') }
        end
      end

      describe 'with a non-matching item' do
        let(:item) do
          Cuprum::Collections::RSpec::Fixtures::BOOKS_FIXTURES
            .find do |book|
              book['title'] == 'The Word for World is Forest'
            end
        end

        it { expect(scope.match?(item: item)).to be false }
      end

      describe 'with a matching item' do
        let(:item) do
          Cuprum::Collections::RSpec::Fixtures::BOOKS_FIXTURES
            .find do |book|
              book['title'] == 'The Ones Who Walk Away From Omelas'
            end
        end

        it { expect(scope.match?(item: item)).to be true }
      end
    end

    context 'when the scope has a greater than or equal to criterion' do
      let(:criteria) do
        described_class.parse do
          { 'published_at' => greater_than_or_equal_to('1972-03-13') }
        end
      end

      describe 'with a non-matching item' do
        let(:item) do
          Cuprum::Collections::RSpec::Fixtures::BOOKS_FIXTURES
            .find do |book|
              book['title'] == 'A Wizard of Earthsea'
            end
        end

        it { expect(scope.match?(item: item)).to be false }
      end

      describe 'with a matching item' do
        let(:item) do
          Cuprum::Collections::RSpec::Fixtures::BOOKS_FIXTURES
            .find do |book|
              book['title'] == 'The Word for World is Forest'
            end
        end

        it { expect(scope.match?(item: item)).to be true }
      end
    end

    context 'when the scope has a less than criterion' do
      let(:criteria) do
        described_class.parse do
          { 'published_at' => less_than('1972-03-13') }
        end
      end

      describe 'with a non-matching item' do
        let(:item) do
          Cuprum::Collections::RSpec::Fixtures::BOOKS_FIXTURES
            .find do |book|
              book['title'] == 'The Word for World is Forest'
            end
        end

        it { expect(scope.match?(item: item)).to be false }
      end

      describe 'with a matching item' do
        let(:item) do
          Cuprum::Collections::RSpec::Fixtures::BOOKS_FIXTURES
            .find do |book|
              book['title'] == 'A Wizard of Earthsea'
            end
        end

        it { expect(scope.match?(item: item)).to be true }
      end
    end

    context 'when the scope has a less than or equal to criterion' do
      let(:criteria) do
        described_class.parse do
          { 'published_at' => less_than_or_equal_to('1972-03-13') }
        end
      end

      describe 'with a non-matching item' do
        let(:item) do
          Cuprum::Collections::RSpec::Fixtures::BOOKS_FIXTURES
            .find do |book|
              book['title'] == 'The Ones Who Walk Away From Omelas'
            end
        end

        it { expect(scope.match?(item: item)).to be false }
      end

      describe 'with a matching item' do
        let(:item) do
          Cuprum::Collections::RSpec::Fixtures::BOOKS_FIXTURES
            .find do |book|
              book['title'] == 'The Word for World is Forest'
            end
        end

        it { expect(scope.match?(item: item)).to be true }
      end
    end

    context 'when the scope has a not equal criterion' do
      let(:criteria) do
        described_class.parse do
          { 'author' => not_equal('J.R.R. Tolkien') }
        end
      end

      describe 'with a non-matching item' do
        let(:item) do
          Cuprum::Collections::RSpec::Fixtures::BOOKS_FIXTURES
            .find { |book| book['title'] == 'The Silmarillion' }
        end

        it { expect(scope.match?(item: item)).to be false }
      end

      describe 'with a matching item' do
        let(:item) do
          Cuprum::Collections::RSpec::Fixtures::BOOKS_FIXTURES
            .find { |book| book['title'] == 'A Wizard of Earthsea' }
        end

        it { expect(scope.match?(item: item)).to be true }
      end
    end

    context 'when the scope has a not one of criterion' do
      let(:criteria) do
        described_class.parse do
          titles = ['The Fellowship Of The Ring', 'The Two Towers']

          { 'title' => not_one_of(titles) }
        end
      end

      describe 'with a non-matching item' do
        let(:item) do
          Cuprum::Collections::RSpec::Fixtures::BOOKS_FIXTURES
            .find { |book| book['title'] == 'The Two Towers' }
        end

        it { expect(scope.match?(item: item)).to be false }
      end

      describe 'with a matching item' do
        let(:item) do
          Cuprum::Collections::RSpec::Fixtures::BOOKS_FIXTURES
            .find { |book| book['title'] == 'The Return of the King' }
        end

        it { expect(scope.match?(item: item)).to be true }
      end
    end

    context 'when the scope has a one of criterion' do
      let(:criteria) do
        described_class.parse do
          titles = ['The Fellowship Of The Ring', 'The Two Towers']

          { 'title' => one_of(titles) }
        end
      end

      describe 'with a non-matching item' do
        let(:item) do
          Cuprum::Collections::RSpec::Fixtures::BOOKS_FIXTURES
            .find { |book| book['title'] == 'The Return of the King' }
        end

        it { expect(scope.match?(item: item)).to be false }
      end

      describe 'with a matching item' do
        let(:item) do
          Cuprum::Collections::RSpec::Fixtures::BOOKS_FIXTURES
            .find { |book| book['title'] == 'The Two Towers' }
        end

        it { expect(scope.match?(item: item)).to be true }
      end
    end

    context 'when the scope has multiple criteria' do
      let(:criteria) do
        described_class.parse do
          titles = ['The Fellowship Of The Ring', 'The Two Towers']

          { 'author' => 'J.R.R. Tolkien', 'title' => not_one_of(titles) }
        end
      end

      describe 'with a non-matching item' do
        let(:item) do
          Cuprum::Collections::RSpec::Fixtures::BOOKS_FIXTURES
            .find { |book| book['title'] == 'The Two Towers' }
        end

        it { expect(scope.match?(item: item)).to be false }
      end

      describe 'with a matching item' do
        let(:item) do
          Cuprum::Collections::RSpec::Fixtures::BOOKS_FIXTURES
            .find { |book| book['title'] == 'The Return of the King' }
        end

        it { expect(scope.match?(item: item)).to be true }
      end
    end

    context 'when the scope has invalid criteria' do
      let(:criteria) { [['title', :random, nil]] }
      let(:item) do
        Cuprum::Collections::RSpec::Fixtures::BOOKS_FIXTURES
          .find { |book| book['title'] == 'The Two Towers' }
      end
      let(:error_class) do
        Cuprum::Collections::Scopes::Criteria::UnknownOperatorException
      end
      let(:error_message) do
        'unknown operator "random"'
      end

      it 'should raise an exception' do
        expect { scope.match?(item: item) }
          .to raise_error error_class, error_message
      end
    end
  end
end
