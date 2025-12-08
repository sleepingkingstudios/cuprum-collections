# frozen_string_literal: true

require 'rspec/sleeping_king_studios/deferred/provider'

require 'cuprum/collections/rspec/deferred'

module Cuprum::Collections::RSpec::Deferred
  # Deferred examples for testing collection adapters.
  module AdapterExamples
    include RSpec::SleepingKingStudios::Deferred::Provider

    deferred_context 'when initialized with attribute names' do
      let(:configured_attribute_names) do
        next valid_attribute_names if defined?(valid_attribute_names)

        %w[title author series]
      end
      let(:constructor_options) do
        super().merge(attribute_names: configured_attribute_names)
      end
    end

    deferred_context 'with parameters for verifying adapters' do
      let(:configured_invalid_attribute_names) do
        next invalid_attribute_names if defined?(invalid_attribute_names)

        %w[invalid_attribute other_invalid_attribute]
      end
      let(:configured_invalid_attributes) do
        next invalid_attributes if defined?(invalid_attributes)

        {}
      end
      let(:configured_partial_attributes) do
        next partial_attributes if defined?(partial_attributes)

        { series: 'The Locked Tomb' }
      end
      let(:configured_valid_attributes) do
        next valid_attributes if defined?(valid_attributes)

        {
          title:  'Gideon the Ninth',
          author: 'Tamsyn Muir'
        }
      end
      let(:configured_invalid_entity) do
        next invalid_entity if defined?(invalid_entity)

        build_entity(configured_invalid_attributes)
      end
      let(:configured_valid_entity) do
        next valid_entity if defined?(valid_entity)

        build_entity(configured_valid_attributes)
      end
      let(:configured_contract) do
        next contract if defined?(contract)

        type    = 'spec.example_constraint'
        message = 'is not a valid data object'

        Stannum::Constraint.new(message:, type:) do |entity|
          value =
            if entity.respond_to?(:title)
              entity.title
            elsif entity.respond_to?(:[])
              entity[:title] || entity['title']
            end

          value.is_a?(String) && !value.empty?
        end
      end
    end

    deferred_examples 'should implement the Adapter interface' do
      describe '#allow_extra_attributes?' do
        include_examples 'should define predicate', :allow_extra_attributes?
      end

      describe '#attribute_names' do
        include_examples 'should define reader',
          :attribute_names,
          lambda {
            be_a(Set)
              .and(satisfy { |set| set.all? { |item| item.is_a?(String) } })
          }
      end

      describe '#build' do
        let(:attributes) { configured_valid_attributes }

        define_method :call_adapter_method do
          subject.build(attributes:)
        end

        include_deferred 'with parameters for verifying adapters'

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
          let(:attributes) { nil }

          include_deferred 'should validate the attributes parameter'
        end

        describe 'with attributes: an Object' do
          let(:attributes) { Object.new.freeze }

          include_deferred 'should validate the attributes parameter'
        end

        describe 'with attributes: a Hash with invalid keys' do
          let(:attributes) do
            super().merge({
              nil    => 'null',
              ''     => 'blank',
              10_000 => 'km'
            })
          end
          let(:expected_failures) do
            [
              "attribute key nil can't be blank",
              "attribute key \"\" can't be blank",
              'attribute key 10000 is not a String or a Symbol'
            ]
          end

          include_deferred 'should validate the attributes parameter'
        end
      end

      describe '#default_contract' do
        include_examples 'should define reader', :default_contract
      end

      describe '#entity_class' do
        include_examples 'should define reader', :entity_class
      end

      describe '#merge' do
        let(:attributes) { configured_partial_attributes }
        let(:entity)     { configured_valid_entity }

        define_method :call_adapter_method do
          subject.merge(attributes:, entity:)
        end

        include_deferred 'with parameters for verifying adapters'

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
          let(:attributes) { nil }

          include_deferred 'should validate the attributes parameter'
        end

        describe 'with attributes: an Object' do
          let(:attributes) { Object.new.freeze }

          include_deferred 'should validate the attributes parameter'
        end

        describe 'with attributes: a Hash with invalid keys' do
          let(:attributes) do
            super().merge({
              nil    => 'null',
              ''     => 'blank',
              10_000 => 'km'
            })
          end
          let(:expected_failures) do
            [
              "attribute key nil can't be blank",
              "attribute key \"\" can't be blank",
              'attribute key 10000 is not a String or a Symbol'
            ]
          end

          include_deferred 'should validate the attributes parameter'
        end
      end

      describe '#serialize' do
        let(:entity) { configured_valid_entity }

        define_method :call_adapter_method do
          subject.serialize(entity:)
        end

        include_deferred 'with parameters for verifying adapters'

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
        let(:entity)  { configured_valid_entity }
        let(:options) { {} }

        define_method :call_adapter_method do
          subject.validate(entity:, **options)
        end

        include_deferred 'with parameters for verifying adapters'

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

    deferred_examples 'should implement the Adapter methods' do
      describe '#build' do
        let(:attributes)     { configured_valid_attributes }
        let(:expected_value) { build_entity(attributes) }

        define_method :call_adapter_method do
          subject.build(attributes:)
        end

        include_deferred 'with parameters for verifying adapters'

        describe 'with an empty Hash' do
          let(:attributes) { {} }

          it 'should return a passing result' do
            expect(call_adapter_method)
              .to be_a_passing_result
              .with_value(expected_value)
          end
        end

        describe 'with a Hash with String keys' do
          let(:attributes) { super().transform_keys(&:to_s) }

          it 'should return a passing result' do
            expect(call_adapter_method)
              .to be_a_passing_result
              .with_value(expected_value)
          end
        end

        describe 'with a Hash with Symbol keys' do
          let(:attributes) { super().transform_keys(&:to_sym) }

          it 'should return a passing result' do
            expect(call_adapter_method)
              .to be_a_passing_result
              .with_value(expected_value)
          end
        end
      end

      describe '#merge' do
        let(:attributes) { configured_partial_attributes }
        let(:entity)     { configured_valid_entity }
        let(:expected_attributes) do
          configured_valid_attributes.merge(attributes)
        end
        let(:expected_value) { build_entity(expected_attributes) }

        define_method :call_adapter_method do
          subject.merge(attributes:, entity:)
        end

        include_deferred 'with parameters for verifying adapters'

        describe 'with an empty Hash' do
          let(:attributes) { {} }

          it 'should return a passing result' do
            expect(call_adapter_method)
              .to be_a_passing_result
              .with_value(expected_value)
          end
        end

        describe 'with a Hash with String keys' do
          let(:attributes) { super().transform_keys(&:to_s) }

          it 'should return a passing result' do
            expect(call_adapter_method)
              .to be_a_passing_result
              .with_value(expected_value)
          end
        end

        describe 'with a Hash with Symbol keys' do
          let(:attributes) { super().transform_keys(&:to_sym) }

          it 'should return a passing result' do
            expect(call_adapter_method)
              .to be_a_passing_result
              .with_value(expected_value)
          end
        end
      end

      describe '#serialize' do
        let(:entity)         { configured_valid_entity }
        let(:expected_value) { serialize_entity(entity).transform_keys(&:to_s) }

        define_method :call_adapter_method do
          subject.serialize(entity:)
        end

        include_deferred 'with parameters for verifying adapters'

        it 'should return a passing result' do
          expect(call_adapter_method)
            .to be_a_passing_result
            .with_value(expected_value)
        end
      end
    end

    deferred_examples 'should validate the attributes parameter' do
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

    deferred_examples 'should validate the attribute names' do
      let(:expected_error) do
        Cuprum::Collections::Errors::ExtraAttributes.new(
          entity_class:     adapter.entity_class,
          extra_attributes: attributes.keys,
          valid_attributes: adapter.attribute_names.to_a
        )
      end

      it 'should return a failing result' do
        expect(call_adapter_method)
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end

    deferred_examples 'should validate the attribute names by entity class' do
      describe '#build' do
        let(:attributes) do
          configured_invalid_attribute_names.to_h { |key| [key, 'value'] }
        end

        define_method :call_adapter_method do
          subject.build(attributes:)
        end

        include_deferred 'with parameters for verifying adapters'

        describe 'with an attributes Hash with extra Strings' do
          let(:attributes) { super().transform_keys(&:to_s) }

          include_deferred 'should validate the attribute names'
        end

        describe 'with an attributes Hash with extra Symbols' do
          let(:attributes) { super().transform_keys(&:to_sym) }

          include_deferred 'should validate the attribute names'
        end
      end

      describe '#merge' do
        let(:attributes) do
          configured_invalid_attribute_names.to_h { |key| [key, 'value'] }
        end
        let(:entity) { configured_valid_entity }

        define_method :call_adapter_method do
          subject.merge(attributes:, entity:)
        end

        include_deferred 'with parameters for verifying adapters'

        describe 'with an attributes Hash with extra Strings' do
          let(:attributes) { super().transform_keys(&:to_s) }

          include_deferred 'should validate the attribute names'
        end

        describe 'with an attributes Hash with extra Symbols' do
          let(:attributes) { super().transform_keys(&:to_sym) }

          include_deferred 'should validate the attribute names'
        end
      end
    end

    deferred_examples 'should validate the attribute names by parameter' do
      describe '#build' do
        let(:attributes) do
          configured_invalid_attribute_names.to_h { |key| [key, 'value'] }
        end

        define_method :call_adapter_method do
          subject.build(attributes:)
        end

        include_deferred 'with parameters for verifying adapters'

        wrap_deferred 'when initialized with attribute names' do
          describe 'with an attributes Hash with extra Strings' do
            let(:attributes) { super().transform_keys(&:to_s) }

            include_deferred 'should validate the attribute names'
          end

          describe 'with an attributes Hash with extra Symbols' do
            let(:attributes) { super().transform_keys(&:to_sym) }

            include_deferred 'should validate the attribute names'
          end
        end
      end

      describe '#merge' do
        let(:attributes) do
          configured_invalid_attribute_names.to_h { |key| [key, 'value'] }
        end
        let(:entity) { configured_valid_entity }

        define_method :call_adapter_method do
          subject.merge(attributes:, entity:)
        end

        include_deferred 'with parameters for verifying adapters'

        wrap_deferred 'when initialized with attribute names' do
          describe 'with an attributes Hash with extra Strings' do
            let(:attributes) { super().transform_keys(&:to_s) }

            include_deferred 'should validate the attribute names'
          end

          describe 'with an attributes Hash with extra Symbols' do
            let(:attributes) { super().transform_keys(&:to_sym) }

            include_deferred 'should validate the attribute names'
          end
        end
      end
    end

    deferred_examples 'should validate the entity parameter' do
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

    deferred_examples 'should validate the entity by fixed class' do
      describe '#merge' do
        let(:attributes) { configured_partial_attributes }
        let(:entity)     { configured_valid_entity }

        define_method :call_adapter_method do
          subject.merge(attributes:, entity:)
        end

        include_deferred 'with parameters for verifying adapters'

        describe 'with entity: nil' do
          let(:entity) { nil }

          include_deferred 'should validate the entity parameter'
        end

        describe 'with entity: an Object' do
          let(:entity) { Object.new.freeze }

          include_deferred 'should validate the entity parameter'
        end
      end

      describe '#serialize' do
        let(:entity) { configured_valid_entity }

        define_method :call_adapter_method do
          subject.serialize(entity:)
        end

        include_deferred 'with parameters for verifying adapters'

        describe 'with entity: nil' do
          let(:entity) { nil }

          include_deferred 'should validate the entity parameter'
        end

        describe 'with entity: an Object' do
          let(:entity) { Object.new.freeze }

          include_deferred 'should validate the entity parameter'
        end
      end

      describe '#validate' do
        let(:entity)  { configured_valid_entity }
        let(:options) { {} }

        define_method :call_adapter_method do
          subject.validate(entity:, **options)
        end

        include_deferred 'with parameters for verifying adapters'

        describe 'with entity: nil' do
          let(:entity) { nil }

          include_deferred 'should validate the entity parameter'
        end

        describe 'with entity: an Object' do
          let(:entity) { Object.new.freeze }

          include_deferred 'should validate the entity parameter'
        end
      end
    end

    deferred_examples 'should validate the entity by optional parameter' do
      describe '#merge' do
        let(:attributes) { configured_partial_attributes }
        let(:entity)     { configured_valid_entity }

        define_method :call_adapter_method do
          subject.merge(attributes:, entity:)
        end

        include_deferred 'with parameters for verifying adapters'

        wrap_deferred 'when initialized with an entity class' do
          describe 'with entity: nil' do
            let(:entity) { nil }

            include_deferred 'should validate the entity parameter'
          end

          describe 'with entity: an Object' do
            let(:entity) { Object.new.freeze }

            include_deferred 'should validate the entity parameter'
          end
        end
      end

      describe '#serialize' do
        let(:entity) { configured_valid_entity }

        define_method :call_adapter_method do
          subject.serialize(entity:)
        end

        include_deferred 'with parameters for verifying adapters'

        wrap_deferred 'when initialized with an entity class' do
          describe 'with entity: nil' do
            let(:entity) { nil }

            include_deferred 'should validate the entity parameter'
          end

          describe 'with entity: an Object' do
            let(:entity) { Object.new.freeze }

            include_deferred 'should validate the entity parameter'
          end
        end
      end

      describe '#validate' do
        let(:entity)  { configured_valid_entity }
        let(:options) { {} }

        define_method :call_adapter_method do
          subject.validate(entity:, **options)
        end

        include_deferred 'with parameters for verifying adapters'

        wrap_deferred 'when initialized with an entity class' do
          describe 'with entity: nil' do
            let(:entity) { nil }

            include_deferred 'should validate the entity parameter'
          end

          describe 'with entity: an Object' do
            let(:entity) { Object.new.freeze }

            include_deferred 'should validate the entity parameter'
          end
        end
      end
    end

    deferred_examples 'should validate the entity by required parameter' do
      describe '#merge' do
        let(:attributes) { configured_partial_attributes }
        let(:entity)     { configured_valid_entity }

        define_method :call_adapter_method do
          subject.merge(attributes:, entity:)
        end

        include_deferred 'with parameters for verifying adapters'

        describe 'with entity: nil' do
          let(:entity) { nil }

          include_deferred 'should validate the entity parameter'
        end

        describe 'with entity: an Object' do
          let(:entity) { Object.new.freeze }

          include_deferred 'should validate the entity parameter'
        end
      end

      describe '#serialize' do
        let(:entity) { configured_valid_entity }

        define_method :call_adapter_method do
          subject.serialize(entity:)
        end

        include_deferred 'with parameters for verifying adapters'

        describe 'with entity: nil' do
          let(:entity) { nil }

          include_deferred 'should validate the entity parameter'
        end

        describe 'with entity: an Object' do
          let(:entity) { Object.new.freeze }

          include_deferred 'should validate the entity parameter'
        end
      end

      describe '#validate' do
        let(:entity)  { configured_valid_entity }
        let(:options) { {} }

        define_method :call_adapter_method do
          subject.validate(entity:, **options)
        end

        include_deferred 'with parameters for verifying adapters'

        describe 'with entity: nil' do
          let(:entity) { nil }

          include_deferred 'should validate the entity parameter'
        end

        describe 'with entity: an Object' do
          let(:entity) { Object.new.freeze }

          include_deferred 'should validate the entity parameter'
        end
      end
    end

    deferred_examples 'should validate the entity using the default contract' do
      describe '#validate' do
        let(:entity)  { configured_valid_entity }
        let(:options) { {} }
        let(:expected_error) do
          Cuprum::Collections::Errors::MissingDefaultContract
            .new(entity_class: adapter.entity_class)
        end

        define_method :call_adapter_method do
          subject.validate(entity:, **options)
        end

        include_deferred 'with parameters for verifying adapters'

        it 'should return a failing result' do
          expect(call_adapter_method)
            .to be_a_failing_result
            .with_error(expected_error)
        end

        describe 'with contract: value' do
          let(:options) { super().merge(contract: configured_contract) }

          describe 'when the entity does not match the contract' do
            let(:entity) { configured_invalid_entity }
            let(:expected_error) do
              errors = configured_contract.errors_for(entity)

              Cuprum::Collections::Errors::FailedValidation.new(
                entity_class: adapter.entity_class,
                errors:
              )
            end

            it 'should return a failing result' do
              expect(call_adapter_method)
                .to be_a_failing_result
                .with_error(expected_error)
            end
          end

          describe 'when the entity matches the contract' do
            let(:entity) { configured_valid_entity }

            it 'should return a passing result' do
              expect(call_adapter_method)
                .to be_a_passing_result
                .with_value(entity)
            end
          end
        end

        context 'when initialized with a default contract' do
          let(:constructor_options) do
            super().merge(default_contract: configured_contract)
          end

          describe 'when the entity does not match the contract' do
            let(:entity) { configured_invalid_entity }
            let(:expected_error) do
              errors = configured_contract.errors_for(entity)

              Cuprum::Collections::Errors::FailedValidation.new(
                entity_class: adapter.entity_class,
                errors:
              )
            end

            it 'should return a failing result' do
              expect(call_adapter_method)
                .to be_a_failing_result
                .with_error(expected_error)
            end
          end

          describe 'when the entity matches the contract' do
            let(:entity) { configured_valid_entity }

            it 'should return a passing result' do
              expect(call_adapter_method)
                .to be_a_passing_result
                .with_value(entity)
            end
          end

          describe 'with contract: value' do
            let(:options) do
              super().merge(contract: Stannum::Constraints::Nothing.new)
            end
            let(:entity) { configured_valid_entity }
            let(:expected_error) do
              errors = options[:contract].errors_for(entity)

              Cuprum::Collections::Errors::FailedValidation.new(
                entity_class: adapter.entity_class,
                errors:
              )
            end

            it 'should return a failing result' do
              expect(call_adapter_method)
                .to be_a_failing_result
                .with_error(expected_error)
            end
          end
        end
      end
    end
  end
end
