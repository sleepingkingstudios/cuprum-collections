# frozen_string_literal: true

require 'stannum/errors'

require 'cuprum/collections/errors/failed_validation'

RSpec.describe Cuprum::Collections::Errors::FailedValidation do
  subject(:error) { described_class.new(**keywords) }

  let(:entity_class) { Spec::FuelTank }
  let(:errors) do
    errors = Stannum::Errors.new

    errors.add('spec.failed_inspection', message: 'failed inspection')
    errors[:liquid_fuel].add('spec.empty', message: 'is empty')
    errors[:oxidizer].add('spec.leaking', message: 'is leaking')

    errors
  end
  let(:keywords) do
    {
      entity_class:,
      errors:
    }
  end

  example_class 'Spec::FuelTank'

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
          'entity_class' => entity_class.name,
          'errors'       => expected_errors
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

  describe '#errors' do
    include_examples 'should define reader', :errors, -> { errors }
  end

  describe '#message' do
    let(:expected) do
      "#{entity_class.name} failed validation"
    end

    include_examples 'should define reader', :message, -> { be == expected }
  end

  describe '#type' do
    include_examples 'should define reader', :type, described_class::TYPE
  end
end
