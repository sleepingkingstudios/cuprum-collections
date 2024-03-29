# frozen_string_literal: true

require 'rspec/sleeping_king_studios/concerns/shared_example_group'
require 'stannum/rspec/match_errors'

require 'support/examples'

module Spec::Support::Examples
  module ConstraintExamples
    extend  RSpec::SleepingKingStudios::Concerns::SharedExampleGroup
    include Stannum::RSpec::Matchers

    shared_examples 'should implement the Constraint interface' do
      describe '#does_not_match?' do
        it 'should define the method' do
          expect(subject).to respond_to(:does_not_match?).with(1).argument
        end
      end

      describe '#errors_for' do
        it 'should define the method' do
          expect(subject)
            .to respond_to(:errors_for)
            .with(1).argument
            .and_keywords(:errors)
        end
      end

      describe '#match' do
        it { expect(subject).to respond_to(:match).with(1).argument }
      end

      describe '#matches?' do
        it { expect(subject).to respond_to(:matches?).with(1).argument }

        it { expect(subject).to have_aliased_method(:matches?).as(:match?) }
      end

      describe '#message' do
        include_examples 'should have reader', :message
      end

      describe '#negated_errors_for' do
        let(:actual) { Object.new.freeze }

        it 'should define the method' do
          expect(subject)
            .to respond_to(:negated_errors_for)
            .with(1).argument
            .and_keywords(:errors)
        end
      end

      describe '#negated_match' do
        it 'should define the method' do
          expect(subject).to respond_to(:negated_match).with(1).argument
        end
      end

      describe '#negated_message' do
        include_examples 'should have reader', :negated_message
      end

      describe '#negated_type' do
        include_examples 'should have reader', :negated_type
      end

      describe '#options' do
        include_examples 'should have reader', :options
      end

      describe '#type' do
        include_examples 'should have reader', :type
      end

      describe '#with_options' do
        it { expect(subject).to respond_to(:with_options).with_any_keywords }
      end
    end

    shared_examples 'should implement the Constraint methods' do
      describe '#clone' do
        let(:copy) { subject.clone }

        it { expect(copy).not_to be subject }

        it { expect(copy).to be_a described_class }

        it { expect(copy.options).to be == subject.options }

        it 'should duplicate the options' do
          expect { copy.options.update(key: 'value') }
            .not_to change(subject, :options)
        end
      end

      describe '#dup' do
        let(:copy) { subject.dup }

        it { expect(copy).not_to be subject }

        it { expect(copy).to be_a described_class }

        it { expect(copy.options).to be == subject.options }

        it 'should duplicate the options' do
          expect { copy.options.update(key: 'value') }
            .not_to change(subject, :options)
        end
      end

      describe '#errors_for' do
        it { expect(subject.errors_for nil).to be_a Stannum::Errors }
      end

      describe '#match' do
        it 'should return an array with two items' do
          expect(subject.match(nil))
            .to be_a(Array)
            .and(have_attributes(size: 2))
        end

        it { expect(subject.match(nil).first).to be_boolean }

        it { expect(subject.match(nil).last).to be_a(Stannum::Errors) }
      end

      describe '#negated_errors_for' do
        it { expect(subject.negated_errors_for nil).to be_a Stannum::Errors }
      end

      describe '#negated_match' do
        it 'should return an array with two items' do
          expect(subject.negated_match(nil))
            .to be_a(Array)
            .and(have_attributes(size: 2))
        end

        it { expect(subject.negated_match(nil).first).to be_boolean }

        it { expect(subject.negated_match(nil).last).to be_a(Stannum::Errors) }
      end

      describe '#negated_type' do
        it { expect(subject.type).to be == described_class::TYPE }

        context 'when initialized with negated_type: value' do
          let(:constructor_options) do
            super().merge(negated_type: 'spec.negated_type')
          end

          it { expect(subject.negated_type).to be == 'spec.negated_type' }
        end
      end

      describe '#options' do
        let(:expected_options) do
          defined?(super()) ? super() : constructor_options
        end

        it { expect(subject.options).to deep_match expected_options }

        context 'when initialized with options' do
          let(:constructor_options) { super().merge(key: 'value') }
          let(:expected_options)    { super().merge(key: 'value') }

          it { expect(subject.options).to deep_match expected_options }
        end
      end

      describe '#type' do
        it { expect(subject.type).to be == described_class::TYPE }

        context 'when initialized with type: value' do
          let(:constructor_options) { super().merge(type: 'spec.type') }

          it { expect(subject.type).to be == 'spec.type' }
        end
      end

      describe '#with_options' do
        let(:options) { {} }
        let(:copy)    { subject.with_options(**options) }

        it { expect(copy).not_to be subject }

        it { expect(copy).to be_a described_class }

        it { expect(copy.options).to be == subject.options }

        it 'should duplicate the options' do
          expect { copy.options.update(key: 'value') }
            .not_to change(subject, :options)
        end

        describe 'with options' do
          let(:options)          { { key: 'value' } }
          let(:expected_options) { subject.options.merge(options) }

          it { expect(copy.options).to be == expected_options }
        end
      end
    end

    shared_examples 'should match the constraint' do
      let(:actual_status) do
        status, _ = subject.send(match_method, actual)

        status
      end
      let(:actual_errors) do
        _, errors = subject.send(match_method, actual)

        errors
      end

      it { expect(actual_status).to be true }

      it { expect(actual_errors).to match_errors(Stannum::Errors.new) }
    end

    shared_examples 'should not match the constraint' do
      let(:actual_status) do
        status, _ = subject.send(match_method, actual)

        status
      end
      let(:actual_errors) do
        _, errors = subject.send(match_method, actual)

        errors
      end
      # :nocov:
      let(:wrapped_errors) do
        errors =
          if expected_errors.is_a?(Array)
            expected_errors
          else
            [expected_errors]
          end

        errors
          .map do |error|
            {
              data:    {},
              message: nil,
              path:    []
            }.merge(error)
          end
      end
      let(:wrapped_messages) do
        errors =
          if expected_messages.is_a?(Array)
            expected_messages
          else
            [expected_messages]
          end

        errors
          .map do |error|
            {
              data:    {},
              message: nil,
              path:    []
            }.merge(error)
          end
      end
      # :nocov:

      it { expect(actual_status).to be false }

      it { expect(actual_errors).to match_errors wrapped_errors }

      if instance_methods.include?(:expected_messages)
        # :nocov:
        it 'should generate the error messages' do
          expect(actual_errors.with_messages).to match_errors wrapped_messages
        end
        # :nocov:
      end
    end
  end
end
