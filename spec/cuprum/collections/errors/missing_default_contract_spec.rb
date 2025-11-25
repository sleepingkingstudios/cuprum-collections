# frozen_string_literal: true

require 'cuprum/collections/errors/missing_default_contract'

RSpec.describe Cuprum::Collections::Errors::MissingDefaultContract do
  subject(:error) { described_class.new(**options) }

  let(:options) { {} }

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
    let(:entity_class) { nil }
    let(:expected) do
      {
        'data'    => {
          'entity_class' => entity_class&.name
        },
        'message' => error.message,
        'type'    => error.type
      }
    end

    include_examples 'should have reader', :as_json, -> { be == expected }

    describe 'with entity_class: nil' do
      let(:options) { super().merge(entity_class: nil) }

      example_class 'Spec::FuelTank'

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
    include_examples 'should define reader', :entity_class, nil

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

  describe '#message' do
    let(:expected) do
      'attempted to validate an entity, but the entity class does not ' \
        'define a default contract'
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
        "attempted to validate a #{entity_class.name}, but " \
          "#{entity_class.name} does not define a default contract"
      end

      example_class 'Spec::FuelTank'

      it { expect(error.message).to be == expected }
    end
  end

  describe '#type' do
    include_examples 'should define reader', :type, described_class::TYPE
  end
end
