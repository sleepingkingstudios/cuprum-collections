# frozen_string_literal: true

require 'cuprum/collections/basic/scopes/conjunction_scope'
require 'cuprum/collections/basic/scopes/criteria_scope'
require 'cuprum/collections/rspec/contracts/scope_contracts'
require 'cuprum/collections/rspec/contracts/scopes/logical_contracts'

RSpec.describe Cuprum::Collections::Basic::Scopes::ConjunctionScope do
  include Cuprum::Collections::RSpec::Contracts::ScopeContracts
  include Cuprum::Collections::RSpec::Contracts::Scopes::LogicalContracts

  subject(:scope) { described_class.new(scopes:) }

  let(:scopes) { [] }
  let(:data) { [] }

  def build_scope(filters = nil, &block)
    scope_class = Cuprum::Collections::Basic::Scopes::CriteriaScope

    if block_given?
      scope_class.build(&block)
    else
      scope_class.build(filters)
    end
  end

  def filtered_data
    scope.call(data:)
  end

  include_contract 'should be a conjunction scope'

  describe '#call' do
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
  end

  describe '#match?' do
    let(:item) { {} }

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

    context 'when the scope has no child scopes' do
      let(:scopes) { [] }

      describe 'with an item' do
        let(:item) do
          Cuprum::Collections::RSpec::Fixtures::BOOKS_FIXTURES
            .find { |book| book['title'] == 'The Silmarillion' }
        end

        it { expect(scope.match?(item:)).to be true }
      end
    end

    context 'when the scope has one child scope' do
      let(:scopes) do
        [
          build_scope({ 'author' => 'J.R.R. Tolkien' })
        ]
      end

      describe 'with an item that does not match the scope' do
        let(:item) do
          Cuprum::Collections::RSpec::Fixtures::BOOKS_FIXTURES
            .find { |book| book['title'] == 'A Wizard of Earthsea' }
        end

        it { expect(scope.match?(item:)).to be false }
      end

      describe 'with an item that matches the scope' do
        let(:item) do
          Cuprum::Collections::RSpec::Fixtures::BOOKS_FIXTURES
            .find { |book| book['title'] == 'The Silmarillion' }
        end

        it { expect(scope.match?(item:)).to be true }
      end
    end

    context 'when the scope has many child scopes' do
      let(:scopes) do
        [
          build_scope({ 'author' => 'J.R.R. Tolkien' }),
          build_scope({ 'series' => 'The Lord of the Rings' }),
          build_scope do |scope|
            { 'published_at' => scope.less_than('1955-01-01') }
          end
        ]
      end

      describe 'with an item that does not match any of the scopes' do
        let(:item) do
          Cuprum::Collections::RSpec::Fixtures::BOOKS_FIXTURES
            .find { |book| book['title'] == 'A Wizard of Earthsea' }
        end

        it { expect(scope.match?(item:)).to be false }
      end

      describe 'with an item that matches some of the scopes' do
        let(:item) do
          Cuprum::Collections::RSpec::Fixtures::BOOKS_FIXTURES
            .find { |book| book['title'] == 'The Hobbit' }
        end

        it { expect(scope.match?(item:)).to be false }
      end

      describe 'with an item that matches all of the scopes' do
        let(:item) do
          Cuprum::Collections::RSpec::Fixtures::BOOKS_FIXTURES
            .find { |book| book['title'] == 'The Fellowship of the Ring' }
        end

        it { expect(scope.match?(item:)).to be true }
      end
    end
  end
end
