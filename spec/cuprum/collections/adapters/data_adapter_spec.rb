# frozen_string_literal: true

require 'cuprum/collections/adapters/data_adapter'
require 'cuprum/collections/rspec/deferred/adapter_examples'

RSpec.describe Cuprum::Collections::Adapters::DataAdapter do
  include Cuprum::Collections::RSpec::Deferred::AdapterExamples

  subject(:adapter) { described_class.new(**constructor_options) }

  let(:entity_class)        { Spec::BookData }
  let(:constructor_options) { { entity_class: } }

  example_constant 'Spec::BookData' do
    Data.define(:title, :author, :series)
  end

  define_method :build_entity do |attributes|
    attributes = tools.hash_tools.convert_keys_to_symbols(attributes)
    attributes = { title: nil, author: nil, series: nil }.merge(attributes)

    entity_class.new(**attributes)
  end

  define_method :serialize_entity do |entity|
    entity.to_h
  end

  define_method :tools do
    SleepingKingStudios::Tools::Toolbelt.instance
  end

  describe '.new' do
    describe 'with allow_extra_attributes: true' do
      let(:constructor_options) { super().merge(allow_extra_attributes: true) }
      let(:error_message) do
        'adapter does not support extra attributes'
      end

      it 'should raise an exception' do
        expect { described_class.new(**constructor_options) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with attribute_names: invalid members' do
      let(:attribute_names)     { %w[title author publisher published_at] }
      let(:constructor_options) { super().merge(attribute_names:) }
      let(:error_message) do
        'attribute names publisher, published_at are not members of ' \
          "#{entity_class.name}"
      end

      it 'should raise an exception' do
        expect { described_class.new(**constructor_options) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with entity_class: nil' do
      let(:entity_class) { nil }
      let(:error_message) do
        SleepingKingStudios::Tools::Toolbelt
          .instance
          .assertions
          .error_message_for(
            'sleeping_king_studios.tools.assertions.class',
            as: 'entity class'
          )
      end

      it 'should raise an exception' do
        expect { described_class.new(**constructor_options) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with entity_class: a Class' do
      let(:entity_class) { Class.new }
      let(:error_message) do
        'entity class is not a subclass of Data'
      end

      it 'should raise an exception' do
        expect { described_class.new(**constructor_options) }
          .to raise_error ArgumentError, error_message
      end
    end
  end

  include_deferred 'should implement the Adapter interface'

  include_deferred 'should implement the Adapter methods'

  include_deferred 'should validate the attribute names by entity class'

  include_deferred 'should validate the attribute names by parameter'

  include_deferred 'should validate the entity by required parameter'

  include_deferred 'should validate the entity using the default contract'

  describe '#allow_extra_attributes?' do
    it { expect(adapter.allow_extra_attributes?).to be false }
  end

  describe '#attribute_names' do
    let(:expected) { Set.new(entity_class.members.map(&:to_s)) }

    it { expect(adapter.attribute_names).to be_a Set }

    it { expect(adapter.attribute_names).to match_array(expected) }

    context 'when initialized with attribute_names: an Array of Strings' do
      let(:attribute_names)     { %w[title author] }
      let(:constructor_options) { super().merge(attribute_names:) }
      let(:expected)            { attribute_names }

      it { expect(adapter.attribute_names).to match_array(expected) }
    end

    context 'when initialized with attribute_names: an Array of Symbols' do
      let(:attribute_names)     { %i[title author] }
      let(:constructor_options) { super().merge(attribute_names:) }
      let(:expected)            { attribute_names.map(&:to_s) }

      it { expect(adapter.attribute_names).to match_array(expected) }
    end
  end

  describe '#default_contract' do
    it { expect(adapter.default_contract).to be nil }

    context 'when initialized with a default contract' do
      let(:constructor_options) do
        super().merge(default_contract: configured_contract)
      end

      include_deferred 'with parameters for verifying adapters'

      it { expect(adapter.default_contract).to be configured_contract }
    end
  end

  describe '#entity_class' do
    it { expect(adapter.entity_class).to be entity_class }
  end
end
