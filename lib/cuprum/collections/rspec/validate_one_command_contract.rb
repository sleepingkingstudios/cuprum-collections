# frozen_string_literal: true

require 'cuprum/collections/rspec'

module Cuprum::Collections::RSpec
  # Contract validating the behavior of a ValidateOne command implementation.
  VALIDATE_ONE_COMMAND_CONTRACT = lambda do |default_contract:|
    describe '#call' do
      it 'should validate the :contract keyword' do
        expect(command)
          .to validate_parameter(:call, :contract)
          .with_value(Object.new.freeze)
          .using_constraint(Stannum::Constraints::Base, optional: true)
      end

      it 'should validate the :entity keyword' do
        expect(command)
          .to validate_parameter(:call, :entity)
          .with_value(Object.new.freeze)
          .using_constraint(entity_type)
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
              expect(command.call(entity: entity))
                .to be_a_failing_result
                .with_error(expected_error)
            end
          end

          context 'when the entity matches the default contract' do
            let(:attributes) { valid_default_attributes }

            it 'should return a passing result' do
              expect(command.call(entity: entity))
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
            expect(command.call(entity: entity))
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
              errors:       errors
            )
          end

          it 'should return a failing result' do
            expect(command.call(contract: contract, entity: entity))
              .to be_a_failing_result
              .with_error(expected_error)
          end
        end

        context 'when the entity matches the contract' do
          let(:attributes) { valid_attributes }

          it 'should return a passing result' do
            expect(command.call(contract: contract, entity: entity))
              .to be_a_passing_result
              .with_value(entity)
          end
        end
      end
    end
  end
end
