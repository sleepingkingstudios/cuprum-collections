# frozen_string_literal: true

require 'bronze/basic'
require 'bronze/basic/collection'

RSpec.describe Bronze::Basic do
  describe '.new' do
    let(:name)    { 'books' }
    let(:data)    { [] }
    let(:options) { { key: 'value' } }
    let(:constructor_options) do
      {
        name:,
        data:,
        **options
      }
    end
    let(:collection)       { described_class.new(**constructor_options) }
    let(:expected_options) { options.merge(default_entity_class: Hash) }

    define_method :tools do
      SleepingKingStudios::Tools::Toolbelt.instance
    end

    before(:example) { allow(tools.core_tools).to receive(:deprecate) }

    it 'should define the class method' do
      expect(described_class)
        .to respond_to(:new)
        .with(0).arguments
        .and_any_keywords
    end

    it 'should print a deprecation warning' do # rubocop:disable RSpec/ExampleLength
      described_class.new(**constructor_options)

      expect(tools.core_tools)
        .to have_received(:deprecate)
        .with(
          'Bronze::Basic.new',
          'Use Bronze::Basic::Collection.new instead.'
        )
    end

    it { expect(collection).to be_a Bronze::Basic::Collection }

    it { expect(collection.data).to be == data }

    it { expect(collection.name).to be == name }

    it { expect(collection.options).to be == expected_options }
  end
end
