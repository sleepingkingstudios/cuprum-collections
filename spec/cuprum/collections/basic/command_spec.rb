# frozen_string_literal: true

require 'cuprum/collections/basic/command'

require 'support/examples/basic/command_examples'

RSpec.describe Cuprum::Collections::Basic::Command do
  include Spec::Support::Examples::Basic::CommandExamples

  subject(:command) { described_class.new(collection:) }

  include_deferred 'with parameters for a basic command'

  include_deferred 'should implement the Basic::Command methods'

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

  describe '#validate_entity' do
    let(:expected_message) { 'entity is not an instance of Hash' }

    it 'should define the private method' do
      expect(command)
        .to respond_to(:validate_entity, true)
        .with(1).argument
        .and_keywords(:as)
    end

    describe 'with nil' do
      it 'should return the error message' do
        expect(command.send(:validate_entity, nil))
          .to be == expected_message
      end
    end

    describe 'with an Object' do
      it 'should return the error message' do
        expect(command.send(:validate_entity, Object.new.freeze))
          .to be == expected_message
      end
    end

    describe 'with an empty Hash' do
      it 'should return an empty Array' do
        expect(command.send(:validate_entity, {})).to be == []
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
          "entity[nil] key can't be blank",
          'entity[0] key is not an instance of String',
          "entity[\"\"] key can't be blank"
        ]
      end

      it 'should return the error messages' do
        expect(command.send(:validate_entity, value))
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
        [
          "entity[nil] key can't be blank",
          'entity[:symbol] key is not an instance of String'
        ]
      end

      it 'should return the error messages' do
        expect(command.send(:validate_entity, value))
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
        expect(command.send(:validate_entity, value)).to be == []
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
      let(:expected_messages) do
        [
          'entity[:name] key is not an instance of String',
          'entity[:quantity] key is not an instance of String',
          'entity[:purpose] key is not an instance of String'
        ]
      end

      it 'should return the error messages' do
        expect(command.send(:validate_entity, value))
          .to be == expected_messages
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
            'properties[0] key is not an instance of String',
            "properties[\"\"] key can't be blank"
          ]
        end

        it 'should return the error messages' do
          expect(command.send(:validate_entity, value, as: 'properties'))
            .to be == expected_messages
        end
      end
    end
  end
end
