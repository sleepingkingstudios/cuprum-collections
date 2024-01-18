# frozen_string_literal: true

require 'cuprum/collections/rspec/contracts/scope_contracts'
require 'cuprum/collections/basic/scopes/null_scope'

RSpec.describe Cuprum::Collections::Basic::Scopes::NullScope do
  include Cuprum::Collections::RSpec::Contracts::ScopeContracts

  subject(:scope) { described_class.new }

  let(:data) { [] }

  def filtered_data
    scope.call(data: data)
  end

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_any_keywords
    end
  end

  include_contract 'should be a null scope'

  describe '#match' do
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

    describe 'with an item' do
      let(:item) do
        Cuprum::Collections::RSpec::Fixtures::BOOKS_FIXTURES
          .find { |book| book['title'] == 'The Silmarillion' }
      end

      it { expect(scope.match?(item: item)).to be true }
    end
  end
end
