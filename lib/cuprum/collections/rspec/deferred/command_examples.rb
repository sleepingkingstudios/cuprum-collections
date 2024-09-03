# frozen_string_literal: true

require 'cuprum/rspec/deferred/parameter_validation_examples'
require 'rspec/sleeping_king_studios/deferred'

require 'cuprum/collections/rspec/deferred'

module Cuprum::Collections::RSpec::Deferred
  # Deferred examples for testing collection commands.
  module CommandExamples
    include RSpec::SleepingKingStudios::Deferred::Provider
    include Cuprum::RSpec::Deferred::ParameterValidationExamples

    deferred_examples 'should implement the CollectionCommand methods' do
      describe '#collection' do
        include_examples 'should define reader', :collection, -> { collection }
      end

      describe '#name' do
        include_examples 'should define reader', :name, -> { collection.name }

        it 'should alias the method' do
          expect(subject).to have_aliased_method(:name).as(:collection_name)
        end
      end

      describe '#primary_key_name' do
        include_examples 'should define reader',
          :primary_key_name,
          -> { collection.primary_key_name }
      end

      describe '#primary_key_type' do
        include_examples 'should define reader',
          :primary_key_type,
          -> { collection.primary_key_type }
      end

      describe '#query' do
        let(:mock_query) { instance_double(Cuprum::Collections::Query) }

        before(:example) do
          allow(collection).to receive(:query).and_return(mock_query)
        end

        it { expect(subject).to respond_to(:query).with(0).arguments }

        it { expect(subject.query).to be mock_query }
      end

      describe '#singular_name' do
        include_examples 'should define reader',
          :singular_name,
          -> { collection.singular_name }

        it 'should alias the method' do
          expect(subject)
            .to have_aliased_method(:singular_name)
            .as(:member_name)
        end
      end
    end

    deferred_examples 'should validate the attributes parameter' do
      describe 'with an invalid attributes value' do
        let(:attributes) { Object.new.freeze }

        include_deferred 'should validate the parameter',
          :attributes,
          'sleeping_king_studios.tools.assertions.instance_of',
          expected: Hash
      end

      describe 'with an attributes value with invalid keys' do
        let(:attributes) do
          {
            nil      => 'NilClass',
            'string' => 'String',
            symbol:     'Symbol'
          }
        end

        include_deferred 'should validate the parameter',
          'attributes[nil] key',
          'sleeping_king_studios.tools.assertions.presence'
      end
    end

    deferred_examples 'should validate the primary key parameter' do
      describe 'with an invalid primary key value' do
        let(:primary_key) { Object.new.freeze }
        let(:expected_error) do
          Cuprum::Errors::InvalidParameters.new(
            command_class: command.class,
            failures:      [
              tools.assertions.error_message_for(
                'sleeping_king_studios.tools.assertions.instance_of',
                as:       'primary_key',
                expected: collection.primary_key_type
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

    deferred_examples 'should validate the primary keys parameter' do
      describe 'with an invalid primary keys value' do
        let(:primary_keys) { Object.new.freeze }

        include_deferred 'should validate the parameter',
          :primary_keys,
          'sleeping_king_studios.tools.assertions.instance_of',
          expected: Array
      end

      describe 'with an attributes value with invalid keys' do
        let(:valid_primary_key_value) do
          defined?(super()) ? super() : 0
        end
        let(:primary_keys) do
          [
            nil,
            Object.new.freeze,
            valid_primary_key_value
          ]
        end
        let(:expected_error) do
          Cuprum::Errors::InvalidParameters.new(
            command_class: command.class,
            failures:      [
              tools.assertions.error_message_for(
                'sleeping_king_studios.tools.assertions.instance_of',
                as:       'primary_keys[0]',
                expected: collection.primary_key_type
              ),
              tools.assertions.error_message_for(
                'sleeping_king_studios.tools.assertions.instance_of',
                as:       'primary_keys[1]',
                expected: collection.primary_key_type
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
