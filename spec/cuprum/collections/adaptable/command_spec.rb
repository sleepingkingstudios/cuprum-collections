# frozen_string_literal: true

require 'cuprum/rspec/deferred/parameter_validation_examples'

require 'cuprum/collections/adaptable/command'
require 'cuprum/collections/collection_command'
require 'cuprum/collections/rspec/deferred/command_examples'

require 'support/book'

RSpec.describe Cuprum::Collections::Adaptable::Command do
  include Cuprum::Collections::RSpec::Deferred::CommandExamples
  include Cuprum::RSpec::Deferred::ParameterValidationExamples

  subject(:command) { described_class.new(collection:) }

  let(:described_class) { Spec::AdaptableCommand }
  let(:adapter) do
    Cuprum::Collections::Adapter.new(**adapter_options)
  end
  let(:adapter_options) { {} }
  let(:collection) do
    Spec::AdaptableCollection.new(
      adapter:,
      name:    'books',
      **collection_options
    )
  end
  let(:collection_options) { {} }

  example_class 'Spec::AdaptableCollection',
    Cuprum::Collections::Collection \
  do |klass|
    klass.define_method :initialize do |adapter:, **options|
      super(**options)

      @adapter = adapter
    end

    klass.attr_reader :adapter
  end

  example_class 'Spec::AdaptableCommand',
    Cuprum::Collections::CollectionCommand \
  do |klass|
    klass.include Cuprum::Collections::Adaptable::Command # rubocop:disable RSpec/DescribedClass
  end

  describe '#adapter' do
    include_examples 'should define reader', :adapter, -> { adapter }
  end

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:collection)
    end
  end

  include_deferred 'should implement the CollectionCommand methods'

  describe '#call' do
    it 'should define the method' do
      expect(command)
        .to respond_to(:call)
        .with_unlimited_arguments
        .and_any_keywords
    end

    it 'should return a failing result with not implemented error' do
      expect(command.call)
        .to be_a_failing_result
        .with_error(an_instance_of Cuprum::Errors::CommandNotImplemented)
    end
  end

  describe '#validate_attributes' do
    let(:expected_message) { 'attributes is not an instance of Hash' }

    it 'should define the private method' do
      expect(command)
        .to respond_to(:validate_attributes, true)
        .with(1).argument
        .and_keywords(:as)
    end

    describe 'with nil' do
      it 'should return the error message' do
        expect(command.send(:validate_attributes, nil))
          .to be == expected_message
      end
    end

    describe 'with an Object' do
      it 'should return the error message' do
        expect(command.send(:validate_attributes, Object.new.freeze))
          .to be == expected_message
      end
    end

    describe 'with an empty Hash' do
      it 'should return an empty Array' do
        expect(command.send(:validate_attributes, {})).to be == []
      end
    end

    describe 'with a Hash with invalid keys' do
      let(:value) do
        {
          nil => 'NilClass',
          0   => 'Integer',
          ''  => 'String'
        }
      end
      let(:expected_messages) do
        [
          "attributes[nil] key can't be blank",
          'attributes[0] key is not a String or a Symbol',
          "attributes[\"\"] key can't be blank"
        ]
      end

      it 'should return the error messages' do
        expect(command.send(:validate_attributes, value))
          .to be == expected_messages
      end
    end

    describe 'with a Hash with mixed keys' do
      let(:value) do
        {
          nil      => 'NilClass',
          'string' => 'String',
          :symbol  => 'Symbol'
        }
      end
      let(:expected_messages) do
        ["attributes[nil] key can't be blank"]
      end

      it 'should return the error messages' do
        expect(command.send(:validate_attributes, value))
          .to be == expected_messages
      end
    end

    describe 'with a Hash with String keys' do
      let(:value) do
        {
          'name'     => 'Self-Sealing Stembolt',
          'quantity' => 10_000,
          'purpose'  => nil
        }
      end

      it 'should return an empty Array' do
        expect(command.send(:validate_attributes, value)).to be == []
      end
    end

    describe 'with a Hash with Symbol keys' do
      let(:value) do
        {
          name:     'Self-Sealing Stembolt',
          quantity: 10_000,
          purpose:  nil
        }
      end

      it 'should return an empty Array' do
        expect(command.send(:validate_attributes, value)).to be == []
      end
    end

    describe 'with as: value' do
      describe 'with a Hash with invalid keys' do
        let(:value) do
          {
            nil => 'NilClass',
            0   => 'Integer',
            ''  => 'String'
          }
        end
        let(:expected_messages) do
          [
            "properties[nil] key can't be blank",
            'properties[0] key is not a String or a Symbol',
            "properties[\"\"] key can't be blank"
          ]
        end

        it 'should return the error messages' do
          expect(command.send(:validate_attributes, value, as: 'properties'))
            .to be == expected_messages
        end
      end
    end
  end

  describe '#validate_entity' do
    it 'should define the private method' do
      expect(command)
        .to respond_to(:validate_entity, true)
        .with(1).argument
        .and_keywords(:as)
    end

    describe 'with nil' do
      it { expect(command.send(:validate_entity, nil)).to be nil }
    end

    describe 'with an Object' do
      it { expect(command.send(:validate_entity, Object.new.freeze)).to be nil }
    end

    context 'when the adapter has an entity class' do
      let(:entity_class)    { Spec::BookEntity }
      let(:adapter_options) { super().merge(entity_class:) }
      let(:error_message)   { 'entity is not an instance of Spec::BookEntity' }

      example_constant 'Spec::BookEntity' do
        Data.define(:title, :author, :series)
      end

      describe 'with nil' do
        it 'should return the error message' do
          expect(command.send(:validate_entity, nil)).to be == error_message
        end
      end

      describe 'with an Object' do
        it 'should return the error message' do
          expect(command.send(:validate_entity, Object.new.freeze))
            .to be == error_message
        end
      end
    end
  end
end
