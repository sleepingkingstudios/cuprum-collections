# frozen_string_literal: true

require 'cuprum/collections/errors/missing_default_contract'

RSpec.describe Cuprum::Collections::Errors::MissingDefaultContract do
  subject(:error) { described_class.new(entity_class: entity_class) }

  let(:entity_class) { Spec::FuelTank }

  example_class 'Spec::FuelTank'

  describe '::TYPE' do
    include_examples 'should define immutable constant',
      :TYPE,
      'cuprum.collections.errors.missing_default_contract'
  end

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:entity_class)
    end
  end

  describe '#as_json' do
    let(:expected) do
      {
        'data'    => {
          'entity_class' => entity_class.name
        },
        'message' => error.message,
        'type'    => error.type
      }
    end

    include_examples 'should have reader', :as_json, -> { be == expected }
  end

  describe '#entity_class' do
    include_examples 'should define reader', :entity_class, -> { entity_class }
  end

  describe '#message' do
    let(:expected) do
      "attempted to validate a #{entity_class.name}, but #{entity_class.name}" \
        ' does not define a default contract'
    end

    include_examples 'should define reader', :message, -> { be == expected }
  end

  describe '#type' do
    include_examples 'should define reader', :type, described_class::TYPE
  end
end
