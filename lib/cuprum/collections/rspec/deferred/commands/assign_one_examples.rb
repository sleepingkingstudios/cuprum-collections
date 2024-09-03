# frozen_string_literal: true

require 'cuprum/collections/rspec/deferred/command_examples'
require 'cuprum/collections/rspec/deferred/commands'

module Cuprum::Collections::RSpec::Deferred::Commands
  # Namespace for deferred example groups for validating AssignOne commands.
  module AssignOneExamples
    include RSpec::SleepingKingStudios::Deferred::Provider

    deferred_examples 'should implement the AssignOne command' \
    do |allow_extra_attributes: true|
      describe '#call' do
        include Cuprum::Collections::RSpec::Deferred::CommandExamples

        shared_examples 'should assign the attributes' do
          it { expect(result).to be_a_passing_result }

          it { expect(result.value).to be_a entity.class }

          it { expect(result.value).to be == expected_value }
        end

        let(:attributes) { {} }
        let(:result) do
          command.call(attributes:, entity:)
        end
        let(:expected_attributes) do
          initial_attributes.merge(attributes)
        end
        let(:expected_value) do
          defined?(super()) ? super() : expected_attributes
        end

        def call_command
          command.call(attributes:, entity:)
        end

        include_deferred 'should validate the attributes parameter'

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

        describe 'with an empty attributes hash' do
          let(:attributes) { {} }

          include_examples 'should assign the attributes'
        end

        describe 'with an attributes hash with partial attributes' do
          let(:attributes) { { title: 'Gideon the Ninth' } }

          include_examples 'should assign the attributes'
        end

        describe 'with an attributes hash with full attributes' do
          let(:attributes) do
            {
              title:    'Gideon the Ninth',
              author:   'Tamsyn Muir',
              series:   'The Locked Tomb',
              category: 'Horror'
            }
          end

          include_examples 'should assign the attributes'
        end

        describe 'with an attributes hash with extra attributes' do
          let(:attributes) do
            {
              title:     'The Book of Lost Tales',
              audiobook: true
            }
          end

          if allow_extra_attributes
            include_examples 'should assign the attributes'
          else
            # :nocov:
            let(:valid_attributes) do
              defined?(super()) ? super() : expected_attributes.keys
            end
            let(:expected_error) do
              Cuprum::Collections::Errors::ExtraAttributes.new(
                entity_class:     entity.class,
                extra_attributes: %w[audiobook],
                valid_attributes:
              )
            end

            it 'should return a failing result' do
              expect(result).to be_a_failing_result.with_error(expected_error)
            end
            # :nocov:
          end
        end

        context 'when the entity has existing attributes' do
          let(:initial_attributes) do
            # :nocov:
            if defined?(super())
              super().merge(fixtures_data.first)
            else
              fixtures_data.first
            end
            # :nocov:
          end

          describe 'with an empty attributes hash' do
            let(:attributes) { {} }

            include_examples 'should assign the attributes'
          end

          describe 'with an attributes hash with partial attributes' do
            let(:attributes) { { title: 'Gideon the Ninth' } }

            include_examples 'should assign the attributes'
          end

          describe 'with an attributes hash with full attributes' do
            let(:attributes) do
              {
                title:    'Gideon the Ninth',
                author:   'Tamsyn Muir',
                series:   'The Locked Tomb',
                category: 'Horror'
              }
            end

            include_examples 'should assign the attributes'
          end

          describe 'with an attributes hash with extra attributes' do
            let(:attributes) do
              {
                title:     'The Book of Lost Tales',
                audiobook: true
              }
            end

            if allow_extra_attributes
              include_examples 'should assign the attributes'
            else
              # :nocov:
              let(:valid_attributes) do
                defined?(super()) ? super() : expected_attributes.keys
              end
              let(:expected_error) do
                Cuprum::Collections::Errors::ExtraAttributes.new(
                  entity_class:     entity.class,
                  extra_attributes: %w[audiobook],
                  valid_attributes:
                )
              end

              it 'should return a failing result' do
                expect(result)
                  .to be_a_failing_result
                  .with_error(expected_error)
              end
              # :nocov:
            end
          end
        end
      end
    end
  end
end
