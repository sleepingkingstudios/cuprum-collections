# frozen_string_literal: true

require 'cuprum/collections/rspec/deferred/command_examples'
require 'cuprum/collections/rspec/deferred/commands'

module Cuprum::Collections::RSpec::Deferred::Commands
  # Namespace for deferred example groups for validating BuildOne commands.
  module BuildOneExamples
    include RSpec::SleepingKingStudios::Deferred::Provider

    deferred_examples 'should implement the BuildOne command' \
    do |allow_extra_attributes: true|
      describe '#call' do
        include Cuprum::Collections::RSpec::Deferred::CommandExamples

        shared_examples 'should build the entity' do
          it { expect(result).to be_a_passing_result }

          it { expect(result.value).to be == expected_value }
        end

        let(:attributes) { {} }
        let(:result)     { command.call(attributes:) }
        let(:expected_attributes) do
          attributes
        end
        let(:expected_value) do
          defined?(super()) ? super() : attributes
        end

        def call_command
          command.call(attributes:)
        end

        include_deferred 'should validate the attributes parameter'

        describe 'with an empty attributes hash' do
          let(:attributes) { {} }

          include_examples 'should build the entity'
        end

        describe 'with an attributes hash with partial attributes' do
          let(:attributes) { { title: 'Gideon the Ninth' } }

          include_examples 'should build the entity'
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

          include_examples 'should build the entity'
        end

        describe 'with an attributes hash with extra attributes' do
          let(:attributes) do
            {
              'title'     => 'The Book of Lost Tales',
              'audiobook' => true
            }
          end

          if allow_extra_attributes
            include_examples 'should build the entity'
          else
            # :nocov:
            let(:valid_attributes) do
              defined?(super()) ? super() : expected_attributes.keys
            end
            let(:expected_error) do
              Cuprum::Collections::Errors::ExtraAttributes.new(
                entity_class:,
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
      end
    end
  end
end
