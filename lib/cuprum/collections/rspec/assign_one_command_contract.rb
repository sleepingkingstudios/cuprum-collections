# frozen_string_literal: true

require 'stannum/constraints/types/hash_with_indifferent_keys'
require 'stannum/rspec/validate_parameter'

require 'stannum/constraints/presence'

require 'cuprum/collections/rspec'
require 'cuprum/collections/rspec/fixtures'

module Cuprum::Collections::RSpec
  # Contract validating the behavior of an Assign command implementation.
  ASSIGN_ONE_COMMAND_CONTRACT = lambda do |allow_extra_attributes:|
    describe '#call' do
      shared_examples 'should assign the attributes' do
        it { expect(result).to be_a_passing_result }

        it { expect(result.value).to be_a entity.class }

        it { expect(result.value).to be == expected_value }
      end

      let(:attributes) { {} }
      let(:result)     { command.call(attributes: attributes, entity: entity) }
      let(:expected_attributes) do
        initial_attributes.merge(attributes)
      end
      let(:expected_value) do
        defined?(super()) ? super() : expected_attributes
      end

      it 'should validate the :attributes keyword' do
        expect(command)
          .to validate_parameter(:call, :attributes)
          .using_constraint(
            Stannum::Constraints::Types::HashWithIndifferentKeys.new
          )
      end

      it 'should validate the :entity keyword' do
        expect(command)
          .to validate_parameter(:call, :attributes)
          .using_constraint(entity_type)
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
            author:   'Tammsyn Muir',
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
              valid_attributes: valid_attributes
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
            super().merge(BOOKS_FIXTURES.first)
          else
            BOOKS_FIXTURES.first
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
              author:   'Tammsyn Muir',
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
end
