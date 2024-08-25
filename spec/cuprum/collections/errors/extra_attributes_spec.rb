# frozen_string_literal: true

require 'cuprum/collections/errors/extra_attributes'

RSpec.describe Cuprum::Collections::Errors::ExtraAttributes do
  subject(:error) { described_class.new(**keywords) }

  let(:entity_class)     { Spec::FuelTank }
  let(:extra_attributes) { %w[isp thrust] }
  let(:valid_attributes) { %w[cost mass type volume] }
  let(:keywords) do
    {
      entity_class:,
      extra_attributes:,
      valid_attributes:
    }
  end

  example_class 'Spec::FuelTank'

  describe '::TYPE' do
    include_examples 'should define immutable constant',
      :TYPE,
      'cuprum.collections.errors.extra_attributes'
  end

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:entity_class, :extra_attributes, :valid_attributes)
    end
  end

  describe '#as_json' do
    let(:expected) do
      {
        'data'    => {
          'entity_class'     => entity_class.name,
          'extra_attributes' => extra_attributes,
          'valid_attributes' => valid_attributes
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

  describe '#extra_attributes' do
    include_examples 'should define reader',
      :extra_attributes,
      -> { extra_attributes }
  end

  describe '#message' do
    let(:expected) do
      "invalid attributes for #{entity_class.name}: isp, thrust"
    end

    include_examples 'should define reader', :message, -> { be == expected }
  end

  describe '#type' do
    include_examples 'should define reader', :type, described_class::TYPE
  end

  describe '#valid_attributes' do
    include_examples 'should define reader',
      :valid_attributes,
      -> { valid_attributes }
  end
end
