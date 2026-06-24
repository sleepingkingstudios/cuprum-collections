# frozen_string_literal: true

require 'bronze/basic/scopes/none_scope'
require 'bronze/rspec/deferred/scopes/none_examples'

RSpec.describe Bronze::Basic::Scopes::NoneScope do
  include Bronze::RSpec::Deferred::Scopes::NoneExamples

  subject(:scope) { described_class.new }

  let(:data) { [] }

  def filtered_data
    scope.call(data:)
  end

  describe '.instance' do
    let(:expected) { described_class.instance }

    include_examples 'should define class reader', :instance

    it { expect(described_class.instance).to be_a described_class }

    it { expect(described_class.instance).to be expected }
  end

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_any_keywords
    end
  end

  include_deferred 'should implement the NoneScope methods'

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
        Bronze::RSpec::Fixtures::BOOKS_FIXTURES
          .find { |book| book['title'] == 'The Silmarillion' }
      end

      it { expect(scope.match?(item:)).to be false }
    end
  end
end
