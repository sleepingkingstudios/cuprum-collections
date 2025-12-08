# frozen_string_literal: true

require 'stannum/constraint'

require 'cuprum/collections/adapter'
require 'cuprum/collections/rspec/deferred/adapter_examples'

RSpec.describe Cuprum::Collections::Adapter do
  include Cuprum::Collections::RSpec::Deferred::AdapterExamples

  subject(:adapter) { described_class.new(**constructor_options) }

  let(:constructor_options) { {} }

  define_method(:build_entity) { |attributes| attributes }

  deferred_context 'when initialized with an entity class' do
    let(:entity_class)        { Spec::BookEntity }
    let(:constructor_options) { super().merge(entity_class:) }

    example_class 'Spec::BookEntity', Struct.new(:title, :author, :series) \
    do |klass|
      klass.define_singleton_method :contract do
        type    = 'spec.example_constraint'
        message = 'is not a valid data object'

        Stannum::Constraint.new(message:, type:) do |value|
          value.respond_to?(:[]) &&
            value[:series].is_a?(String) &&
            !value[:series].empty?
        end
      end
    end
  end

  deferred_context 'with an adapter class that validates entities' do
    let(:described_class) { Spec::ValidatedAdapter }

    # rubocop:disable RSpec/DescribedClass
    example_class 'Spec::ValidatedAdapter', Cuprum::Collections::Adapter \
    do |klass|
      klass.define_method :validate_entity do |entity, as: 'entity'|
        return if entity.respond_to?(:title)

        "#{as} does not respond to :title"
      end
    end
    # rubocop:enable RSpec/DescribedClass
  end

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:entity_class)
    end

    context 'with an adapter class that validates entity classes' do
      let(:described_class) { Spec::ValidatedAdapter }
      let(:error_message) do
        SleepingKingStudios::Tools::Toolbelt
          .instance
          .assertions
          .error_message_for(
            'sleeping_king_studios.tools.assertions.class',
            as: 'entity class'
          )
      end

      # rubocop:disable RSpec/DescribedClass
      example_class 'Spec::ValidatedAdapter', Cuprum::Collections::Adapter \
      do |klass|
        klass.define_method :validate_entity_class do |entity_class|
          tools.assertions.validate_class(entity_class, as: 'entity class')
        end
      end
      # rubocop:enable RSpec/DescribedClass

      it 'should raise an exception' do
        expect { described_class.new(**constructor_options) }
          .to raise_error ArgumentError, error_message
      end

      describe 'with entity class: an invalid value' do
        let(:entity_class)        { 'Spec::EntityClass' }
        let(:constructor_options) { super().merge(entity_class:) }

        it 'should raise an exception' do
          expect { described_class.new(**constructor_options) }
            .to raise_error ArgumentError, error_message
        end
      end
    end
  end

  include_deferred 'should implement the Adapter interface'

  include_deferred 'should validate the attribute names by parameter'

  include_deferred 'should validate the entity by optional parameter'

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
    let(:attributes) { { 'title' => 'Gideon the Ninth' } }
    let(:expected_error) do
      Cuprum::Errors::CommandNotImplemented
        .new(command: adapter)
    end

    it 'should return a failing result' do
      expect(adapter.build(attributes:))
        .to be_a_failing_result
        .with_error(expected_error)
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
    wrap_deferred 'when initialized with an entity class' do
      it { expect(adapter.entity_class).to be entity_class }
    end
  end

  describe '#merge' do
    let(:attributes) { { 'title' => 'Gideon the Ninth' } }
    let(:entity)     { Struct.new(:title).new }
    let(:expected_error) do
      Cuprum::Errors::CommandNotImplemented
        .new(command: adapter)
    end

    it 'should return a failing result' do
      expect(adapter.merge(attributes:, entity:))
        .to be_a_failing_result
        .with_error(expected_error)
    end

    wrap_deferred 'when initialized with an entity class' do
      let(:entity) { entity_class.new }

      it 'should return a failing result' do
        expect(adapter.merge(attributes:, entity:))
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end

    wrap_deferred 'with an adapter class that validates entities' do
      let(:attributes)        { { 'title' => 'Gideon the Ninth' } }
      let(:expected_failures) { ['entity does not respond to :title'] }

      define_method :call_adapter_method do
        adapter.merge(attributes:, entity:)
      end

      describe 'with entity: nil' do
        let(:entity) { nil }

        include_deferred 'should validate the entity parameter'
      end

      describe 'with entity: an Object' do
        let(:entity) { Object.new.freeze }

        include_deferred 'should validate the entity parameter'
      end

      describe 'with entity: a valid entity' do
        let(:entity) { Struct.new(:title).new }

        it 'should return a failing result' do
          expect(adapter.merge(attributes:, entity:))
            .to be_a_failing_result
            .with_error(expected_error)
        end
      end
    end
  end

  describe '#serialize' do
    wrap_deferred 'when initialized with an entity class' do
      describe 'with entity: a valid entity' do
        let(:entity) { entity_class.new }
        let(:expected_error) do
          Cuprum::Errors::CommandNotImplemented
            .new(command: adapter)
        end

        it 'should return a failing result' do
          expect(adapter.serialize(entity:))
            .to be_a_failing_result
            .with_error(expected_error)
        end
      end
    end

    wrap_deferred 'with an adapter class that validates entities' do
      let(:expected_failures) { ['entity does not respond to :title'] }

      define_method :call_adapter_method do
        adapter.serialize(entity:)
      end

      describe 'with entity: nil' do
        let(:entity) { nil }

        include_deferred 'should validate the entity parameter'
      end

      describe 'with entity: an Object' do
        let(:entity) { Object.new.freeze }

        include_deferred 'should validate the entity parameter'
      end

      describe 'with entity: a valid entity' do
        let(:entity) { Struct.new(:title).new }
        let(:expected_error) do
          Cuprum::Errors::CommandNotImplemented
            .new(command: adapter)
        end

        it 'should return a failing result' do
          expect(adapter.serialize(entity:))
            .to be_a_failing_result
            .with_error(expected_error)
        end
      end
    end
  end

  describe '#validate' do
    let(:entity) { Struct.new(:title).new }
    let(:expected_error) do
      Cuprum::Collections::Errors::MissingDefaultContract
        .new(entity_class: nil)
    end

    it 'should return a failing result' do
      expect(adapter.validate(entity:))
        .to be_a_failing_result
        .with_error(expected_error)
    end

    wrap_deferred 'when initialized with an entity class' do
      let(:entity) { entity_class.new }
      let(:expected_error) do
        Cuprum::Collections::Errors::MissingDefaultContract
          .new(entity_class:)
      end

      it 'should return a failing result' do
        expect(adapter.validate(entity:))
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end

    wrap_deferred 'with an adapter class that validates entities' do
      let(:expected_failures) { ['entity does not respond to :title'] }

      define_method :call_adapter_method do
        adapter.validate(entity:)
      end

      describe 'with entity: nil' do
        let(:entity) { nil }

        include_deferred 'should validate the entity parameter'
      end

      describe 'with entity: an Object' do
        let(:entity) { Object.new.freeze }

        include_deferred 'should validate the entity parameter'
      end

      describe 'with entity: a valid entity' do
        let(:entity) { Struct.new(:title).new }
        let(:expected_error) do
          Cuprum::Collections::Errors::MissingDefaultContract
            .new(entity_class: nil)
        end

        it 'should return a failing result' do
          expect(adapter.validate(entity:))
            .to be_a_failing_result
            .with_error(expected_error)
        end
      end
    end

    describe 'with an adapter class that delegates to native validation' do
      let(:described_class) { Spec::NativeAdapter }

      # rubocop:disable RSpec/DescribedClass
      example_class 'Spec::NativeAdapter', Cuprum::Collections::Adapter \
      do |klass|
        klass.define_method :match_native_validation do |entity:|
          entity_class.contract.match(entity)
        end
      end
      # rubocop:enable RSpec/DescribedClass

      include_deferred 'when initialized with an entity class'

      describe 'when the entity does not match the contract' do
        let(:entity) { entity_class.new }
        let(:expected_error) do
          errors = entity_class.contract.errors_for(entity)

          Cuprum::Collections::Errors::FailedValidation.new(
            entity_class:,
            errors:
          )
        end

        it 'should return a failing result' do
          expect(adapter.validate(entity:))
            .to be_a_failing_result
            .with_error(expected_error)
        end
      end

      describe 'when the entity matches the contract' do
        let(:entity) { entity_class.new(series: 'The Locked Tomb') }

        it 'should return a passing result' do
          expect(adapter.validate(entity:))
            .to be_a_passing_result
            .with_value(entity)
        end
      end

      describe 'with contract: value' do
        let(:contract) do
          type    = 'spec.example_constraint'
          message = 'is not a valid data object'

          Stannum::Constraint.new(message:, type:) do |value|
            value.respond_to?(:[]) &&
              value[:title].is_a?(String) &&
              !value[:title].empty?
          end
        end

        describe 'when the entity does not match the contract' do
          let(:entity) { entity_class.new }
          let(:expected_error) do
            errors = contract.errors_for(entity)

            Cuprum::Collections::Errors::FailedValidation.new(
              entity_class:,
              errors:
            )
          end

          it 'should return a failing result' do
            expect(adapter.validate(contract:, entity:))
              .to be_a_failing_result
              .with_error(expected_error)
          end
        end

        describe 'when the entity matches the contract' do
          let(:entity) { entity_class.new(title: 'Gideon the Ninth') }

          it 'should return a passing result' do
            expect(adapter.validate(contract:, entity:))
              .to be_a_passing_result
              .with_value(entity)
          end
        end
      end

      context 'when initialized with a default contract' do
        let(:constructor_options) do
          super().merge(default_contract: configured_contract)
        end

        include_deferred 'with parameters for verifying adapters'

        describe 'when the entity does not match the contract' do
          let(:entity) { entity_class.new }
          let(:expected_error) do
            errors = configured_contract.errors_for(entity)

            Cuprum::Collections::Errors::FailedValidation.new(
              entity_class:,
              errors:
            )
          end

          it 'should return a failing result' do
            expect(adapter.validate(entity:))
              .to be_a_failing_result
              .with_error(expected_error)
          end
        end

        describe 'when the entity matches the contract' do
          let(:entity) { entity_class.new(title: 'Gideon the Ninth') }

          it 'should return a passing result' do
            expect(adapter.validate(entity:))
              .to be_a_passing_result
              .with_value(entity)
          end
        end
      end
    end
  end
end
