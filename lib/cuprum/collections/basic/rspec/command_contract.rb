# frozen_string_literal: true

require 'cuprum/collections/basic/rspec'

module Cuprum::Collections::Basic::RSpec
  # Contract validating the behavior of a basic command implementation.
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

    describe '#primary_key_name' do
      include_examples 'should have reader', :primary_key_name, :id

      context 'when initialized with a primary key name' do
        let(:primary_key_name) { :uuid }
        let(:constructor_options) do
          super().merge({ primary_key_name: primary_key_name })
        end

        it { expect(command.primary_key_name).to be == primary_key_name }
      end
    end

    describe '#primary_key_type' do
      include_examples 'should have reader', :primary_key_type, Integer

      context 'when initialized with a primary key type' do
        let(:primary_key_type) { String }
        let(:constructor_options) do
          super().merge({ primary_key_type: primary_key_type })
        end

        it { expect(command.primary_key_type).to be == primary_key_type }
      end
    end
  end
end
