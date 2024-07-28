# frozen_string_literal: true

require 'cuprum/collections/errors/unknown_operator'

RSpec.describe Cuprum::Collections::Errors::UnknownOperator do
  subject(:error) { described_class.new(operator:) }

  let(:operator) { :neq }

  describe '::TYPE' do
    include_examples 'should define immutable constant',
      :TYPE,
      'cuprum.collections.errors.unknown_operator'
  end

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:operator)
    end
  end

  describe '#as_json' do
    let(:spell_checker) { DidYouMean::SpellChecker.new(dictionary: []) }
    let(:corrections)   { [] }
    let(:expected) do
      {
        'data'    => {
          'corrections' => error.corrections,
          'operator'    => operator
        },
        'message' => error.message,
        'type'    => error.type
      }
    end

    before(:example) do
      allow(DidYouMean::SpellChecker).to receive(:new).and_return(spell_checker)

      allow(spell_checker).to receive(:correct).and_return(corrections)
    end

    include_examples 'should define reader', :as_json

    context 'when there are no corrections for the operator' do
      let(:corrections) { [] }

      it { expect(error.as_json).to be == expected }
    end

    context 'when there are corrections for the operator' do
      let(:corrections) { %i[ne] }

      it { expect(error.as_json).to be == expected }
    end
  end

  describe '#corrections' do
    let(:expected) do
      DidYouMean::SpellChecker
        .new(dictionary: Cuprum::Collections::Queries::VALID_OPERATORS)
        .correct(operator)
    end

    include_examples 'should define reader', :corrections, -> { expected }

    context 'when the operator is a string' do
      let(:operator) { super().to_s }

      it { expect(error.corrections).to be == expected }
    end
  end

  describe '#message' do
    let(:expected) do
      "unknown operator #{operator.inspect}"
    end
    let(:spell_checker) { DidYouMean::SpellChecker.new(dictionary: []) }
    let(:corrections)   { [] }

    before(:example) do
      allow(DidYouMean::SpellChecker).to receive(:new).and_return(spell_checker)

      allow(spell_checker).to receive(:correct).and_return(corrections)
    end

    include_examples 'should define reader', :message

    context 'when there are no corrections for the operator' do
      let(:corrections) { [] }

      it { expect(error.message).to be == expected }
    end

    context 'when there are corrections for the operator' do
      let(:corrections) { %i[ne] }
      let(:expected)    { "#{super()} - did you mean :ne?" }

      it { expect(error.message).to be == expected }
    end
  end

  describe '#operator' do
    include_examples 'should define reader', :operator, -> { operator }
  end

  describe '#type' do
    include_examples 'should define reader', :type, described_class::TYPE
  end
end
