# frozen_string_literal: true

require 'rspec/sleeping_king_studios/concerns/shared_example_group'

require 'support/examples'

module Spec::Support::Examples
  module CommandExamples
    extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

    # :nocov:
    shared_examples 'should validate the keyword' \
    do |keyword, type:, optional: false, arguments: [], keywords: {}, block: nil| # rubocop:disable Layout/LineLength, Metrics/ParameterLists
      describe "with #{keyword}: nil" do
        let(:result) do
          command.call(*arguments, **keywords.merge(keyword => nil), &block)
        end

        if optional
          it { expect(result).to be_a_passing_result }
        else
          let(:contract) do
            Stannum::Contracts::ParametersContract.new
          end
          let(:contract_builder) do
            Stannum::Contracts::ParametersContract::Builder.new(contract)
          end
          let(:expected_errors) do
            contract.errors_for(
              arguments: arguments,
              block:     block,
              keywords:  keywords.merge(keyword => Object.new.freeze)
            )
          end

          before(:example) do
            contract_builder.send(:keyword, keyword, type, optional: optional)
          end

          it 'should return a failing result' do # rubocop:disable RSpec/ExampleLength
            expect(result).to be_a_failing_result.with_error(
              an_instance_of(Cuprum::Collections::Errors::InvalidParameters)
              .and(
                have_attributes(errors: expected_errors)
              )
            )
          end
        end
      end

      describe "with #{keyword}: invalid" do
        let(:result) do
          command.call(
            *arguments,
            **keywords.merge(keyword => Object.new.freeze),
            &block
          )
        end
        let(:contract) do
          Stannum::Contracts::ParametersContract.new
        end
        let(:contract_builder) do
          Stannum::Contracts::ParametersContract::Builder.new(contract)
        end
        let(:expected_errors) do
          contract.errors_for(
            arguments: arguments,
            block:     block,
            keywords:  keywords.merge(keyword => Object.new.freeze)
          )
        end

        before(:example) do
          contract_builder.send(:keyword, keyword, type, optional: optional)
        end

        it 'should return a failing result', :aggregate_failures do
          expect(result).to be_a_failing_result

          expect(result.error)
            .to be_a Cuprum::Collections::Errors::InvalidParameters

          expect(result.error.errors.to_a).to deep_match expected_errors.to_a
        end
      end
    end
    # :nocov:
  end
end
