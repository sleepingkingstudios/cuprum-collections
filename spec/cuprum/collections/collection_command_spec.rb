# frozen_string_literal: true

require 'cuprum/rspec/deferred/parameter_validation_examples'

require 'cuprum/collections/collection_command'
require 'cuprum/collections/rspec/deferred/command_examples'

require 'support/book'

RSpec.describe Cuprum::Collections::CollectionCommand do
  include Cuprum::Collections::RSpec::Deferred::CommandExamples
  include Cuprum::RSpec::Deferred::ParameterValidationExamples

  subject(:command) { described_class.new(collection:) }

  let(:collection) do
    Cuprum::Collections::Collection.new(name: 'books', **collection_options)
  end
  let(:collection_options) { {} }

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

    context 'when the command defines parameter validation' do
      let(:described_class) { Spec::ValidatedCommand }

      # rubocop:disable RSpec/DescribedClass
      example_class 'Spec::ValidatedCommand',
        Cuprum::Collections::CollectionCommand \
      do |klass|
        klass.validate(:name, String)

        klass.define_method(:process) { |name = nil| "Greetings, #{name}!" }
      end
      # rubocop:enable RSpec/DescribedClass

      describe 'with non-matching parameters' do
        def call_command
          command.call
        end

        include_deferred 'should validate the parameter',
          :name,
          'sleeping_king_studios.tools.assertions.instance_of',
          expected: String
      end

      describe 'with matching parameters' do
        it 'should return a passing result' do
          expect(command.call('Programs'))
            .to be_a_passing_result
            .with_value 'Greetings, Programs!'
        end
      end
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

  describe '#validate_primary_key' do
    let(:primary_key_type) { Integer }
    let(:expected_message) do
      'id is not an instance of Integer'
    end

    it 'should define the private method' do
      expect(command)
        .to respond_to(:validate_primary_key, true)
        .with(1).argument
        .and_keywords(:as)
    end

    describe 'with nil' do
      it 'should return the error message' do
        expect(command.send(:validate_primary_key, nil))
          .to be == expected_message
      end
    end

    describe 'with an Object' do
      it 'should return the error message' do
        expect(command.send(:validate_primary_key, Object.new.freeze))
          .to be == expected_message
      end
    end

    describe 'with a String' do
      it 'should return the error message' do
        expect(command.send(:validate_primary_key, '12345'))
          .to be == expected_message
      end
    end

    describe 'with an Integer' do
      it 'should return nil' do
        expect(command.send(:validate_primary_key, 12_345)).to be nil
      end
    end

    describe 'with as: value' do
      let(:expected_message) do
        'key is not an instance of Integer'
      end

      describe 'with a String' do
        it 'should return the error message' do
          expect(command.send(:validate_primary_key, nil, as: 'key'))
            .to be == expected_message
        end
      end

      describe 'with an Integer' do
        it 'should return nil' do
          expect(command.send(:validate_primary_key, 12_345, as: 'key'))
            .to be nil
        end
      end
    end

    context 'when initialized with primary key name: value' do
      let(:primary_key_name) { 'uuid' }
      let(:collection_options) do
        super().merge({ primary_key_name: })
      end
      let(:expected_message) do
        'uuid is not an instance of Integer'
      end

      describe 'with a String' do
        it 'should return the error message' do
          expect(command.send(:validate_primary_key, nil))
            .to be == expected_message
        end
      end

      describe 'with an Integer' do
        it 'should return nil' do
          expect(command.send(:validate_primary_key, 12_345)).to be nil
        end
      end

      describe 'with as: value' do
        let(:expected_message) do
          'key is not an instance of Integer'
        end

        describe 'with a String' do
          it 'should return the error message' do
            expect(command.send(:validate_primary_key, nil, as: 'key'))
              .to be == expected_message
          end
        end

        describe 'with an Integer' do
          it 'should return nil' do
            expect(command.send(:validate_primary_key, 12_345, as: 'key'))
              .to be nil
          end
        end
      end
    end

    context 'when initialized with primary key type: a Class' do
      let(:primary_key_type) { String }
      let(:collection_options) do
        super().merge({ primary_key_type: })
      end
      let(:expected_message) do
        'id is not an instance of String'
      end

      describe 'with an Integer' do
        it 'should return the error message' do
          expect(command.send(:validate_primary_key, nil))
            .to be == expected_message
        end
      end

      describe 'with a String' do
        it 'should return nil' do
          expect(command.send(:validate_primary_key, '12345')).to be nil
        end
      end
    end

    context 'when initialized with primary key type: a constraint' do
      let(:primary_key_type) { Stannum::Constraints::Uuid.new }
      let(:collection_options) do
        super().merge({ primary_key_type: })
      end
      let(:expected_message) do
        'id is not a valid UUID'
      end

      describe 'with a non-matching value' do
        it 'should return the error message' do
          expect(command.send(:validate_primary_key, '12345'))
            .to be == expected_message
        end
      end

      describe 'with a matching value' do
        let(:value) { '00000000-0000-0000-0000-000000000000' }

        it 'should return nil' do
          expect(command.send(:validate_primary_key, value)).to be nil
        end
      end
    end
  end

  describe '#validate_primary_keys' do
    let(:primary_keys)     { nil }
    let(:primary_key_type) { Integer }
    let(:expected_message) do
      'value is not an instance of Array'
    end

    it 'should define the private method' do
      expect(command)
        .to respond_to(:validate_primary_keys, true)
        .with(1).argument
    end

    describe 'with nil' do
      it 'should return the error message' do
        expect(command.send(:validate_primary_keys, nil))
          .to be == expected_message
      end
    end

    describe 'with an Object' do
      it 'should return the error message' do
        expect(command.send(:validate_primary_keys, Object.new.freeze))
          .to be == expected_message
      end
    end

    describe 'with a String' do
      it 'should return the error message' do
        expect(command.send(:validate_primary_keys, '12345'))
          .to be == expected_message
      end
    end

    describe 'with an Integer' do
      it 'should return the error message' do
        expect(command.send(:validate_primary_keys, 12_345))
          .to be == expected_message
      end
    end

    describe 'with an empty Array' do
      it 'should return an empty Array' do
        expect(command.send(:validate_primary_keys, [])).to be == []
      end
    end

    describe 'with an Array with invalid values' do
      let(:value) { [nil, nil, '12345'] }
      let(:expected_messages) do
        [
          'value[0] is not an instance of Integer',
          'value[1] is not an instance of Integer',
          'value[2] is not an instance of Integer'
        ]
      end

      it 'should return the error messages' do
        expect(command.send(:validate_primary_keys, value))
          .to be == expected_messages
      end
    end

    describe 'with an Array with mixed valid and invalid values' do
      let(:value) { [12_345, nil, 67_890] }
      let(:expected_messages) do
        ['value[1] is not an instance of Integer']
      end

      it 'should return the error messages' do
        expect(command.send(:validate_primary_keys, value))
          .to be == expected_messages
      end
    end

    describe 'with an Array with valid values' do
      let(:value) { [12_345, 23_456, 34_567] }

      it 'should return an empty Array' do
        expect(command.send(:validate_primary_keys, value)).to be == []
      end
    end

    describe 'with as: value' do
      let(:value) { [nil, nil, '12345'] }
      let(:expected_messages) do
        [
          'keys[0] is not an instance of Integer',
          'keys[1] is not an instance of Integer',
          'keys[2] is not an instance of Integer'
        ]
      end

      it 'should return the error messages' do
        expect(command.send(:validate_primary_keys, value, as: 'keys'))
          .to be == expected_messages
      end
    end

    context 'when initialized with primary key type: a Class' do
      let(:primary_key_type) { String }
      let(:collection_options) do
        super().merge({ primary_key_type: })
      end

      describe 'with an Array with invalid values' do
        let(:value) { [nil, nil, 12_345] }
        let(:expected_messages) do
          [
            'value[0] is not an instance of String',
            'value[1] is not an instance of String',
            'value[2] is not an instance of String'
          ]
        end

        it 'should return the error messages' do
          expect(command.send(:validate_primary_keys, value))
            .to be == expected_messages
        end
      end

      describe 'with an Array with valid values' do
        let(:value) { %w[12345 23456 34567] }

        it 'should return an empty Array' do
          expect(command.send(:validate_primary_keys, value)).to be == []
        end
      end
    end

    context 'when initialized with primary key type: a constraint' do
      let(:primary_key_type) { Stannum::Constraints::Uuid.new }
      let(:collection_options) do
        super().merge({ primary_key_type: })
      end

      describe 'with an Array with invalid values' do
        let(:value) { [nil, 12_345, '12345'] }
        let(:expected_messages) do
          [
            'value[0] is not a String',
            'value[1] is not a String',
            'value[2] is not a valid UUID'
          ]
        end

        it 'should return the error messages' do
          expect(command.send(:validate_primary_keys, value))
            .to be == expected_messages
        end
      end

      describe 'with an Array with valid values' do
        let(:value) do
          %w[
            00000000-0000-0000-0000-000000000000
            11111111-1111-1111-1111-111111111111
            22222222-2222-2222-2222-222222222222
          ]
        end

        it 'should return an empty Array' do
          expect(command.send(:validate_primary_keys, value)).to be == []
        end
      end
    end
  end
end
