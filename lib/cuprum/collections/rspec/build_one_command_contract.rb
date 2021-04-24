# frozen_string_literal: true

require 'stannum/constraints/types/hash_with_indifferent_keys'
require 'stannum/rspec/validate_parameter'

require 'cuprum/collections/rspec'

module Cuprum::Collections::RSpec
  # Contract validating the behavior of a Build command implementation.
  BUILD_ONE_COMMAND_CONTRACT = lambda do |allow_extra_attributes:|
    include Stannum::RSpec::Matchers

    describe '#call' do
      shared_examples 'should build the entity' do
        it { expect(result).to be_a_passing_result }

        it { expect(result.value).to be == expected_value }
      end

      let(:attributes) { {} }
      let(:result)     { command.call(attributes: attributes) }
      let(:expected_attributes) do
        attributes
      end
      let(:expected_value) do
        defined?(super()) ? super() : attributes
      end

      it 'should validate the :attributes keyword' do
        expect(command)
          .to validate_parameter(:call, :attributes)
          .using_constraint(
            Stannum::Constraints::Types::HashWithIndifferentKeys.new
          )
      end

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
            author:   'Tammsyn Muir',
            series:   'The Locked Tomb',
            category: 'Horror'
          }
        end

        include_examples 'should build the entity'
      end

      describe 'with an attributes hash with extra attributes' do
        let(:attributes) do
          {
            title:     'The Book of Lost Tales',
            audiobook: true
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
              entity_class:     entity_class,
              extra_attributes: %w[audiobook],
              valid_attributes: valid_attributes
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
