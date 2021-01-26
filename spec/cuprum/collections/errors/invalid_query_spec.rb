# frozen_string_literal: true

require 'cuprum/collections/errors/invalid_query'

require 'stannum/errors'

RSpec.describe Cuprum::Collections::Errors::InvalidQuery do
  subject(:error) { described_class.new(**keywords) }

  let(:strategy) { :block }
  let(:errors)   { Stannum::Errors.new }
  let(:keywords) { { errors: errors, strategy: strategy } }

  describe '::TYPE' do
    include_examples 'should define immutable constant',
      :TYPE,
      'cuprum.collections.errors.invalid_query'
  end

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:errors, :message, :strategy)
    end
  end

  describe '#as_json' do
    let(:expected) do
      {
        'data'    => {
          'errors'   => errors.to_a,
          'strategy' => strategy
        },
        'message' => error.message,
        'type'    => error.type
      }
    end

    include_examples 'should have reader', :as_json, -> { be == expected }

    context 'when the error is initialized with message: value' do
      let(:message)  { 'the query is full of eels' }
      let(:keywords) { super().merge(message: message) }

      it { expect(error.as_json).to be == expected }
    end
  end

  describe '#errors' do
    include_examples 'should define reader', :errors, -> { errors }
  end

  describe '#message' do
    let(:expected) do
      "unable to parse query with strategy #{strategy.inspect}"
    end

    include_examples 'should have reader', :message, -> { be == expected }

    context 'when the error is initialized with message: value' do
      let(:message)  { 'the query is full of eels' }
      let(:keywords) { super().merge(message: message) }

      it { expect(error.message).to be == message }
    end
  end

  describe '#strategy' do
    include_examples 'should define reader', :strategy, -> { strategy }
  end

  describe '#type' do
    include_examples 'should define reader', :type, described_class::TYPE
  end
end
