# frozen_string_literal: true

require 'cuprum/collections/adapters/hash_adapter'
require 'cuprum/collections/rspec/deferred/adapter_examples'

RSpec.describe Cuprum::Collections::Adapters::HashAdapter do
  include Cuprum::Collections::RSpec::Deferred::AdapterExamples

  subject(:adapter) { described_class.new(**constructor_options) }

  let(:constructor_options) { {} }

  define_method :build_entity do |attributes|
    attributes = tools.hash_tools.convert_keys_to_strings(attributes)
    empty_hash = adapter.attribute_names.to_h { |key| [key, nil] }

    empty_hash.merge(attributes)
  end

  define_method :serialize_entity do |entity|
    entity.dup
  end

  define_method :tools do
    SleepingKingStudios::Tools::Toolbelt.instance
  end

  describe '.new' do
    describe 'with entity_class: a Class' do
      let(:constructor_options) { super().merge(entity_class: Class.new) }
      let(:error_message) do
        'adapter does not support entity class'
      end

      it 'should raise an exception' do
        expect { described_class.new(**constructor_options) }
          .to raise_error ArgumentError, error_message
      end
    end
  end

  include_deferred 'should implement the Adapter interface'

  include_deferred 'should implement the Adapter methods'

  include_deferred 'should validate the attribute names by parameter'

  include_deferred 'should validate the entity by fixed class'

  include_deferred 'should validate the entity using the default contract'

  describe '#allow_extra_attributes?' do
    it { expect(adapter.allow_extra_attributes?).to be true }

    context 'when initialized with allow_extra_attributes: false' do
      let(:constructor_options) do
        super().merge(allow_extra_attributes: false)
      end

      it { expect(adapter.allow_extra_attributes?).to be false }
    end

    context 'when initialized with allow_extra_attributes: true' do
      let(:constructor_options) do
        super().merge(allow_extra_attributes: true)
      end

      it { expect(adapter.allow_extra_attributes?).to be true }
    end

    wrap_deferred 'when initialized with attribute names' do
      it { expect(adapter.allow_extra_attributes?).to be false }

      context 'when initialized with allow_extra_attributes: false' do
        let(:constructor_options) do
          super().merge(allow_extra_attributes: false)
        end

        it { expect(adapter.allow_extra_attributes?).to be false }
      end

      context 'when initialized with allow_extra_attributes: true' do
        let(:constructor_options) do
          super().merge(allow_extra_attributes: true)
        end

        it { expect(adapter.allow_extra_attributes?).to be true }
      end
    end
  end

  describe '#attribute_names' do
    it { expect(adapter.attribute_names).to be == Set.new }

    context 'when initialized with attribute_names: an Array of Strings' do
      let(:attribute_names)     { %w[title author series] }
      let(:constructor_options) { super().merge(attribute_names:) }
      let(:expected)            { attribute_names }

      it { expect(adapter.attribute_names).to match_array(expected) }
    end

    context 'when initialized with attribute_names: an Array of Symbols' do
      let(:attribute_names)     { %i[title author series] }
      let(:constructor_options) { super().merge(attribute_names:) }
      let(:expected)            { attribute_names.map(&:to_s) }

      it { expect(adapter.attribute_names).to match_array(expected) }
    end
  end

  describe '#build' do
    wrap_deferred 'when initialized with attribute names' do
      let(:attributes)     { configured_valid_attributes }
      let(:expected_value) { build_entity(attributes) }

      define_method :call_adapter_method do
        subject.build(attributes:)
      end

      include_deferred 'with parameters for verifying adapters'

      it 'should return a passing result' do
        expect(call_adapter_method)
          .to be_a_passing_result
          .with_value(expected_value)
      end
    end
  end
end
