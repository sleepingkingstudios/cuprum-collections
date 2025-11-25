# frozen_string_literal: true

require 'stannum/errors'

require 'cuprum/collections/errors/failed_validation'

RSpec.describe Cuprum::Collections::Errors::FailedValidation do
  subject(:error) { described_class.new(**options) }

  let(:errors) do
    errors = Stannum::Errors.new

    errors.add('spec.failed_inspection', message: 'failed inspection')
    errors[:liquid_fuel].add('spec.empty', message: 'is empty')
    errors[:oxidizer].add('spec.leaking', message: 'is leaking')

    errors
  end
  let(:options) { { errors: } }

  describe '::TYPE' do
    include_examples 'should define immutable constant',
      :TYPE,
      'cuprum.collections.errors.failed_validation'
  end

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:entity_class, :errors)
    end
  end

  describe '#as_json' do
    let(:entity_class) { nil }
    let(:expected_errors) do
      {
        ''            => ['failed inspection'],
        'liquid_fuel' => ['is empty'],
        'oxidizer'    => ['is leaking']
      }
    end
    let(:expected) do
      {
        'data'    => {
          'entity_class' => entity_class&.name,
          'errors'       => expected_errors
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

  describe '#errors' do
    include_examples 'should define reader', :errors, -> { errors }
  end

  describe '#message' do
    let(:expected) do
      'an entity failed validation'
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
        "#{entity_class.name} failed validation"
      end

      example_class 'Spec::FuelTank'

      it { expect(error.message).to be == expected }
    end
  end

  describe '#type' do
    include_examples 'should define reader', :type, described_class::TYPE
  end
end
