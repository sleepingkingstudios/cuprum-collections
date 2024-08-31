# frozen_string_literal: true

require 'stannum/constraints/types/hash_with_string_keys'

require 'cuprum/collections/rspec/deferred/command_examples'

require 'support/book'
require 'support/examples/basic'

module Spec::Support::Examples::Basic
  module CommandExamples
    include RSpec::SleepingKingStudios::Deferred::Provider

    deferred_context 'with a collection with a custom primary key' do
      let(:primary_key_name) { :uuid }
      let(:primary_key_type) { String }
      let(:collection_options) do
        super().merge(
          primary_key_name:,
          primary_key_type:
        )
      end
      let(:mapped_data) do
        data.map do |item|
          item.dup.tap do |hsh|
            value = hsh.delete('id').to_s.rjust(12, '0')

            hsh['uuid'] = "00000000-0000-0000-0000-#{value}"
          end
        end
      end
      let(:invalid_primary_key_value) do
        '00000000-0000-0000-0000-000000000100'
      end
      let(:valid_primary_key_value) do
        '00000000-0000-0000-0000-000000000000'
      end
      let(:invalid_primary_key_values) do
        %w[
          00000000-0000-0000-0000-000000000100
          00000000-0000-0000-0000-000000000101
          00000000-0000-0000-0000-000000000102
        ]
      end
      let(:valid_primary_key_values) do
        %w[
          00000000-0000-0000-0000-000000000000
          00000000-0000-0000-0000-000000000001
          00000000-0000-0000-0000-000000000002
        ]
      end
    end

    deferred_context 'with parameters for a basic command' do
      let(:collection) do
        Cuprum::Collections::Basic::Collection.new(
          data: mapped_data,
          name: 'books',
          **collection_options
        )
      end
      let(:collection_options)  { {} }
      let(:data)                { [] }
      let(:mapped_data)         { data }
      let(:fixtures_data) do
        Cuprum::Collections::RSpec::Fixtures::BOOKS_FIXTURES.dup
      end
    end

    deferred_examples 'should implement the Basic::Command methods' do
      include Cuprum::Collections::RSpec::Deferred::CommandExamples

      include_deferred 'should implement the CollectionCommand methods'

      describe '.new' do
        it 'should define the constructor' do
          expect(described_class)
            .to respond_to(:new)
            .with(0).arguments
            .and_keywords(:collection)
        end
      end

      describe '#data' do
        include_examples 'should define reader', :data, -> { collection.data }
      end

      describe '#default_contract' do
        include_examples 'should define reader',
          :default_contract,
          -> { collection.default_contract }
      end
    end

    deferred_examples 'should validate the entity' do
      describe 'with an invalid entity value' do
        let(:entity) { Object.new.freeze }

        include_deferred 'should validate the parameter',
          :entity,
          'sleeping_king_studios.tools.assertions.instance_of',
          expected: Hash
      end

      describe 'with an entity value with invalid keys' do
        let(:entity) do
          {
            nil      => 'NilClass',
            'string' => 'String',
            symbol:     'Symbol'
          }
        end
        let(:expected_error) do
          Cuprum::Errors::InvalidParameters.new(
            command_class: command.class,
            failures:      [
              tools.assertions.error_message_for(
                'sleeping_king_studios.tools.assertions.presence',
                as: 'entity[nil] key'
              ),
              tools.assertions.error_message_for(
                'sleeping_king_studios.tools.assertions.instance_of',
                as:       'entity[:symbol] key',
                expected: String
              )
            ]
          )
        end

        it 'should return a failing result with InvalidParameters error' do
          expect(call_command)
            .to be_a_failing_result
            .with_error(expected_error)
        end
      end
    end
  end
end
