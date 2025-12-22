# frozen_string_literal: true

require 'cuprum/collections/rspec/deferred/command_examples'
require 'cuprum/collections/rspec/deferred/commands'

module Cuprum::Collections::RSpec::Deferred::Commands
  # Namespace for deferred example groups for validating InsertOne commands.
  module InsertOneExamples
    include RSpec::SleepingKingStudios::Deferred::Provider

    deferred_examples 'should implement the InsertOne command' do
      describe '#call' do
        include Cuprum::Collections::RSpec::Deferred::CommandExamples

        let(:matching_data) { attributes }
        let(:expected_data) do
          defined?(super()) ? super() : matching_data
        end
        let(:primary_key_name) do
          defined?(super()) ? super() : 'id'
        end
        let(:primary_key_type) do
          defined?(super()) ? super() : Integer
        end
        let(:scoped) do
          key    = primary_key_name
          value  = entity[primary_key_name.to_s]

          collection.query.where { { key => value } }
        end

        def call_command
          command.call(entity:)
        end

        if defined_deferred_examples? 'should validate the entity'
          include_deferred 'should validate the entity'
        else
          # :nocov:
          pending \
            'the command should validate the entity parameter, but entity ' \
            'validation is not defined - implement a "should validate the ' \
            'entity" deferred example group to resolve this warning'
          # :nocov:
        end

        context 'when the item does not exist in the collection' do
          it 'should return a passing result' do
            expect(command.call(entity:))
              .to be_a_passing_result
              .with_value(match(expected_data))
          end

          it 'should append an item to the collection' do
            expect { command.call(entity:) }
              .to(
                change { collection.query.count }
                .by(1)
              )
          end

          it 'should add the entity to the collection' do
            expect { command.call(entity:) }
              .to change(scoped, :exists?)
              .to be true
          end

          it 'should set the attributes' do
            command.call(entity:)

            expect(scoped.to_a.first).to match(expected_data)
          end
        end

        context 'when the item exists in the collection' do
          let(:data) { fixtures_data }
          let(:expected_error) do
            Cuprum::Collections::Errors::AlreadyExists.new(
              attribute_name:  collection.primary_key_name,
              attribute_value: attributes.fetch(
                primary_key_name.to_s,
                attributes[primary_key_name.intern]
              ),
              name:            collection.name,
              primary_key:     true
            )
          end

          it 'should return a failing result' do
            expect(command.call(entity:))
              .to be_a_failing_result
              .with_error(expected_error)
          end

          it 'should not append an item to the collection' do
            expect { command.call(entity:) }
              .not_to(change { collection.query.count })
          end
        end
      end
    end
  end
end
