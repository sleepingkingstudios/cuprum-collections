# frozen_string_literal: true

require 'cuprum/collections/errors/extra_attributes'

RSpec.describe Cuprum::Collections::Errors::ExtraAttributes do
  subject(:error) { described_class.new(**keywords) }

  let(:entity_class)     { nil }
  let(:extra_attributes) { %w[isp thrust] }
  let(:valid_attributes) { %w[cost mass type volume] }
  let(:options)          { {} }
  let(:keywords) do
    {
      extra_attributes:,
      valid_attributes:,
      **options
    }
  end

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
          'entity_class'     => entity_class&.name,
          'extra_attributes' => extra_attributes,
          'valid_attributes' => valid_attributes
        },
        'message' => error.message,
        'type'    => error.type
      }
    end

    include_examples 'should have reader', :as_json, -> { be == expected }

    describe 'with entity_class: nil' do
      let(:options) { super().merge(entity_class: nil) }

      it { expect(error.as_json).to be == expected }
    end

    describe 'with entity_class: value' do
      let(:entity_class) { Spec::FuelTank }
      let(:options)      { super().merge(entity_class:) }

      example_class 'Spec::FuelTank'

      it { expect(error.as_json).to be == expected }
    end
  end

  describe '#entity_class' do
    include_examples 'should define reader', :entity_class, -> { entity_class }

    describe 'with entity_class: nil' do
      let(:options) { super().merge(entity_class: nil) }

      it { expect(error.entity_class).to be nil }
    end

    describe 'with entity_class: value' do
      let(:entity_class) { Spec::FuelTank }
      let(:options)      { super().merge(entity_class:) }

      example_class 'Spec::FuelTank'

      it { expect(error.entity_class).to be entity_class }
    end
  end

  describe '#extra_attributes' do
    include_examples 'should define reader',
      :extra_attributes,
      -> { extra_attributes }
  end

  describe '#message' do
    let(:expected) do
      'invalid attributes for an entity: isp, thrust'
    end

    include_examples 'should define reader', :message, -> { be == expected }

    describe 'with entity_class: nil' do
      let(:options) { super().merge(entity_class: nil) }

      it { expect(error.message).to be == expected }
    end

    describe 'with entity_class: value' do
      let(:entity_class) { Spec::FuelTank }
      let(:options)      { super().merge(entity_class:) }
      let(:expected) do
        "invalid attributes for #{entity_class.name}: isp, thrust"
      end

      example_class 'Spec::FuelTank'

      it { expect(error.message).to be == expected }
    end
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
