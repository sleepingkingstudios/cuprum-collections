# frozen_string_literal: true

require 'cuprum/collections/rspec/contracts'

module Cuprum::Collections::RSpec::Contracts
  # Contracts for asserting on scope objects.
  module ScopeContracts
    # Contract validating the behavior of a Criteria scope implementation.
    module ShouldBeACriteriaScopeContract
      extend RSpec::SleepingKingStudios::Contract

      # @!method apply(example_group)
      #   Adds the contract to the example group.
      #
      #   @param example_group [RSpec::Core::ExampleGroup] the example group to
      #     which the contract is applied.
      contract do
        shared_context 'with criteria' do
          let(:criteria) do
            [
              ['title', 'eq', 'Gideon the Ninth'],
              ['author', 'eq', 'Tamsyn Muir']
            ]
          end
        end

        let(:criteria) { [] }

        describe '.new' do
          it 'should define the constructor' do
            expect(described_class)
              .to be_constructible
              .with(0).arguments
              .and_keywords(:criteria)
              .and_any_keywords
          end
        end

        describe '#criteria' do
          include_examples 'should define reader', :criteria, -> { criteria }

          wrap_context 'with criteria' do
            it { expect(scope.criteria).to be == criteria }
          end
        end

        describe '#with_criteria' do
          let(:new_criteria) { ['author', 'eq', 'Ursula K. LeGuin'] }

          it { expect(scope).to respond_to(:with_criteria).with(1).argument }

          it 'should return a scope' do
            expect(scope.with_criteria(new_criteria)).to be_a described_class
          end

          it "should not change the original scope's criteria" do
            expect { scope.with_criteria(new_criteria) }
              .not_to change(scope, :criteria)
          end

          it "should set the copied scope's criteria" do
            expect(scope.with_criteria(new_criteria).criteria)
              .to be == new_criteria
          end

          wrap_context 'with criteria' do
            it "should not change the original scope's criteria" do
              expect { scope.with_criteria(new_criteria) }
                .not_to change(scope, :criteria)
            end

            it "should set the copied scope's criteria" do
              expect(scope.with_criteria(new_criteria).criteria)
                .to be == new_criteria
            end
          end
        end
      end
    end
  end
end
