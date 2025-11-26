# frozen_string_literal: true

require 'rspec/sleeping_king_studios/deferred/provider'

require 'cuprum/collections/rspec/deferred'

module Cuprum::Collections::RSpec::Deferred
  # Deferred examples for testing collection adapters.
  module AdapterExamples
    include RSpec::SleepingKingStudios::Deferred::Provider

    deferred_examples 'should validate the attributes' do
      let(:configured_failures) do
        next expected_failures if defined?(expected_failures)

        message =
          SleepingKingStudios::Tools::Toolbelt
            .instance
            .assertions
            .error_message_for(
              'sleeping_king_studios.tools.assertions.instance_of',
              as:       'attributes',
              expected: Hash
            )

        [message]
      end
      let(:expected_error) do
        Cuprum::Errors::InvalidParameters.new(
          command_class: described_class,
          failures:      configured_failures
        )
      end

      it 'should return a failing result' do
        expect(call_adapter_method)
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end

    deferred_examples 'should validate the entity' do
      let(:configured_failures) do
        next expected_failures if defined?(expected_failures)

        message =
          SleepingKingStudios::Tools::Toolbelt
            .instance
            .assertions
            .error_message_for(
              'sleeping_king_studios.tools.assertions.instance_of',
              as:       'entity',
              expected: adapter.entity_class
            )

        [message]
      end
      let(:expected_error) do
        failures = configured_failures

        Cuprum::Errors::InvalidParameters.new(
          command_class: described_class,
          failures:
        )
      end

      it 'should return a failing result' do
        expect(call_adapter_method)
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end

    deferred_examples 'should implement the Adapter interface' do
      describe '#build' do
        let(:configured_attributes) do
          next valid_attributes if defined?(valid_attributes)

          {}
        end

        define_method :call_adapter_method do
          subject.build(attributes: configured_attributes)
        end

        it 'should define the method' do
          expect(subject)
            .to respond_to(:build)
            .with(0).arguments
            .and_keywords(:attributes)
        end

        it 'should return a result' do
          expect(call_adapter_method).to be_a_result
        end

        describe 'with attributes: nil' do
          let(:configured_attributes) { nil }

          include_deferred 'should validate the attributes'
        end

        describe 'with attributes: an Object' do
          let(:configured_attributes) { Object.new.freeze }

          include_deferred 'should validate the attributes'
        end
      end

      describe '#default_contract' do
        include_examples 'should define reader', :default_contract
      end

      describe '#entity_class' do
        include_examples 'should define reader', :entity_class
      end

      describe '#merge' do
        let(:configured_attributes) do
          next valid_attributes if defined?(valid_attributes)

          {}
        end
        let(:configured_entity) do
          next entity if defined?(entity)

          subject.build(attributes: {})
        end

        define_method :call_adapter_method do
          subject.merge(
            attributes: configured_attributes,
            entity:     configured_entity
          )
        end

        it 'should define the method' do
          expect(subject)
            .to respond_to(:merge)
            .with(0).arguments
            .and_keywords(:attributes, :entity)
        end

        it 'should return a result' do
          expect(call_adapter_method).to be_a_result
        end

        describe 'with attributes: nil' do
          let(:configured_attributes) { nil }

          include_deferred 'should validate the attributes'
        end

        describe 'with attributes: an Object' do
          let(:configured_attributes) { Object.new.freeze }

          include_deferred 'should validate the attributes'
        end
      end

      describe '#serialize' do
        let(:configured_entity) do
          next entity if defined?(entity)

          subject.build(attributes: {})
        end

        define_method :call_adapter_method do
          subject.serialize(entity: configured_entity)
        end

        it 'should define the method' do
          expect(subject)
            .to respond_to(:serialize)
            .with(0).arguments
            .and_keywords(:entity)
        end

        it 'should return a result' do
          expect(call_adapter_method).to be_a_result
        end
      end

      describe '#validate' do
        let(:configured_entity) do
          next entity if defined?(entity)

          subject.build(attributes: {})
        end
        let(:configured_options) { {} }

        define_method :call_adapter_method do
          subject.validate(entity: configured_entity, **configured_options)
        end

        it 'should define the method' do
          expect(subject)
            .to respond_to(:validate)
            .with(0).arguments
            .and_keywords(:contract, :entity)
        end

        it 'should return a result' do
          expect(call_adapter_method).to be_a_result
        end
      end
    end
  end
end
