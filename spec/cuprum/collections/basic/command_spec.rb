# frozen_string_literal: true

require 'cuprum/collections/basic/command'

require 'support/examples/basic/command_examples'

RSpec.describe Cuprum::Collections::Basic::Command do
  include Spec::Support::Examples::Basic::CommandExamples

  subject(:command) { described_class.new(collection:) }

  define_method :tools do
    SleepingKingStudios::Tools::Toolbelt.instance
  end

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
    let(:expected_message) do
      tools.assertions.error_message_for(
        :instance_of,
        as:       'entity',
        expected: Hash
      )
    end

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
          tools
            .assertions
            .error_message_for(:presence, as: 'entity[nil] key'),
          tools
            .assertions
            .error_message_for(
              :instance_of,
              as:       'entity[0] key',
              expected: String
            ),
          tools
            .assertions
            .error_message_for(:presence, as: 'entity[""] key')
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
          tools
            .assertions
            .error_message_for(:presence, as: 'entity[nil] key'),
          tools
            .assertions
            .error_message_for(
              :instance_of,
              as:       'entity[:symbol] key',
              expected: String
            )
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
          tools
            .assertions
            .error_message_for(
              :instance_of,
              as:       'entity[:name] key',
              expected: String
            ),
          tools
            .assertions
            .error_message_for(
              :instance_of,
              as:       'entity[:quantity] key',
              expected: String
            ),
          tools
            .assertions
            .error_message_for(
              :instance_of,
              as:       'entity[:purpose] key',
              expected: String
            )
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
            tools
              .assertions
              .error_message_for(:presence, as: 'properties[nil] key'),
            tools
              .assertions
              .error_message_for(
                :instance_of,
                as:       'properties[0] key',
                expected: String
              ),
            tools
              .assertions
              .error_message_for(:presence, as: 'properties[""] key')
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
