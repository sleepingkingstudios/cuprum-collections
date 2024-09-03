# frozen_string_literal: true

require 'cuprum/collections/rspec/deferred/command_examples'
require 'cuprum/collections/rspec/deferred/commands'

module Cuprum::Collections::RSpec::Deferred::Commands
  # Namespace for deferred example groups for validating ValidateOne commands.
  module ValidateOneExamples
    include RSpec::SleepingKingStudios::Deferred::Provider

    deferred_examples 'should implement the ValidateOne command' \
    do |default_contract: false|
      describe '#call' do
        include Cuprum::Collections::RSpec::Deferred::CommandExamples

        let(:attributes) { defined?(super()) ? super() : {} }
        let(:contract)   { defined?(super()) ? super() : nil }

        def call_command
          command.call(contract:, entity:)
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

        describe 'with an invalid contract value' do
          let(:contract) { Object.new.freeze }

          include_deferred 'should validate the parameter',
            :contract,
            'sleeping_king_studios.tools.assertions.instance_of',
            expected: Stannum::Constraints::Base
        end

        describe 'with contract: nil' do
          if default_contract
            context 'when the entity does not match the default contract' do
              let(:attributes) { invalid_default_attributes }
              let(:expected_error) do
                Cuprum::Collections::Errors::FailedValidation.new(
                  entity_class: entity.class,
                  errors:       expected_errors
                )
              end

              it 'should return a failing result' do
                expect(command.call(entity:))
                  .to be_a_failing_result
                  .with_error(expected_error)
              end
            end

            context 'when the entity matches the default contract' do
              let(:attributes) { valid_default_attributes }

              it 'should return a passing result' do
                expect(command.call(entity:))
                  .to be_a_passing_result
                  .with_value(entity)
              end
            end
          else
            let(:attributes) { valid_attributes }
            let(:expected_error) do
              Cuprum::Collections::Errors::MissingDefaultContract.new(
                entity_class: entity.class
              )
            end

            it 'should return a failing result' do
              expect(command.call(entity:))
                .to be_a_failing_result
                .with_error(expected_error)
            end
          end
        end

        describe 'with contract: value' do
          context 'when the entity does not match the contract' do
            let(:attributes) { invalid_attributes }
            let(:errors)     { contract.errors_for(entity) }
            let(:expected_error) do
              Cuprum::Collections::Errors::FailedValidation.new(
                entity_class: entity.class,
                errors:
              )
            end

            it 'should return a failing result' do
              expect(command.call(contract:, entity:))
                .to be_a_failing_result
                .with_error(expected_error)
            end
          end

          context 'when the entity matches the contract' do
            let(:attributes) { valid_attributes }

            it 'should return a passing result' do
              expect(command.call(contract:, entity:))
                .to be_a_passing_result
                .with_value(entity)
            end
          end
        end
      end
    end
  end
end
