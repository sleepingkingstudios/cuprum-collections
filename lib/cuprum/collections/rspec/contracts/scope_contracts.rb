# frozen_string_literal: true

require 'cuprum/collections/rspec/contracts'
require 'cuprum/collections/rspec/fixtures'

module Cuprum::Collections::RSpec::Contracts
  # Contracts for asserting on scope objects.
  module ScopeContracts
    # Contract validating the behavior of a Container scope implementation.
    module ShouldBeAContainerScopeContract
      extend RSpec::SleepingKingStudios::Contract

      # @!method apply(example_group)
      #   Adds the contract to the example group.
      #
      #   @param example_group [RSpec::Core::ExampleGroup] the example group to
      #     which the contract is applied.
      contract do
        shared_context 'with scopes' do
          let(:scopes) do
            [
              described_class.new(scopes: []),
              described_class.new(scopes: []),
              described_class.new(scopes: [])
            ]
          end
        end

        describe '.new' do
          it 'should define the constructor' do
            expect(described_class)
              .to be_constructible
              .with(0).arguments
              .and_keywords(:scopes)
              .and_any_keywords
          end
        end

        describe '#scopes' do
          include_examples 'should define reader', :scopes, -> { scopes }

          wrap_context 'with scopes' do
            it { expect(subject.scopes).to be == scopes }
          end
        end

        describe '#with_scopes' do
          let(:new_scopes) do
            [
              described_class.new(scopes: []),
              described_class.new(scopes: [])
            ]
          end

          it { expect(subject).to respond_to(:with_scopes).with(1).arguments }

          it 'should return a scope' do
            expect(subject.with_scopes(new_scopes)).to be_a described_class
          end

          it "should not change the original scope's child scopes" do
            expect { subject.with_scopes(new_scopes) }
              .not_to change(subject, :scopes)
          end

          it "should set the copied scope's child scopes" do
            expect(subject.with_scopes(new_scopes).scopes)
              .to be == new_scopes
          end

          wrap_context 'with scopes' do
            it "should not change the original scope's child scopes" do
              expect { subject.with_scopes(new_scopes) }
                .not_to change(subject, :scopes)
            end

            it "should set the copied scope's child scopes" do
              expect(subject.with_scopes(new_scopes).scopes)
                .to be == new_scopes
            end
          end
        end
      end
    end
  end
end
