# frozen_string_literal: true

require 'cuprum/collections/reference/rspec'

module Cuprum::Collections::Reference::RSpec
  # Contract validating the behavior of a reference command implementation.
  COMMAND_CONTRACT = lambda do
    describe '#collection_name' do
      include_examples 'should have reader',
        :collection_name,
        -> { collection_name }

      context 'when initialized with collection_name: symbol' do
        let(:collection_name) { :books }

        it { expect(command.collection_name).to be == collection_name.to_s }
      end
    end

    describe '#data' do
      include_examples 'should have reader', :data, -> { data }
    end

    describe '#options' do
      let(:expected_options) do
        defined?(super()) ? super() : constructor_options
      end

      include_examples 'should have reader',
        :options,
        -> { be == expected_options }

      context 'when initialized with options' do
        let(:constructor_options) { super().merge({ key: 'value' }) }
        let(:expected_options)    { super().merge({ key: 'value' }) }

        it { expect(command.options).to be == expected_options }
      end
    end
  end
end
