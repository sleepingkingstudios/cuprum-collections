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

    # Contract validating the behavior of a Negation scope implementation.
    module ShouldFilterDataByLogicalNandContract
      extend RSpec::SleepingKingStudios::Contract

      # @!method apply(example_group)
      #   Adds the contract to the example group.
      #
      #   @param example_group [RSpec::Core::ExampleGroup] the example group to
      #     which the contract is applied.
      contract do
        shared_context 'with data' do
          let(:data) do
            Cuprum::Collections::RSpec::Fixtures::BOOKS_FIXTURES
          end
        end

        context 'when the scope has no child scopes' do
          let(:scopes) { [] }

          describe 'with empty data' do
            let(:data) { [] }

            it { expect(filtered_data).to be == [] }
          end

          wrap_context 'with data' do
            it { expect(filtered_data).to be == [] }
          end
        end

        context 'when the scope has one child scope' do
          let(:scopes) do
            [
              build_scope({ 'author' => 'J.R.R. Tolkien' })
            ]
          end

          describe 'with empty data' do
            let(:data)     { [] }
            let(:expected) { data }

            it { expect(filtered_data).to be == expected }
          end

          wrap_context 'with data' do
            let(:expected) do
              data.reject { |item| item['author'] == 'J.R.R. Tolkien' }
            end

            it { expect(filtered_data).to be == expected }
          end
        end

        context 'when the scope has many child scopes' do
          let(:scopes) do
            [
              build_scope({ 'author' => 'J.R.R. Tolkien' }),
              build_scope({ 'series' => 'The Lord of the Rings' }),
              build_scope do
                { 'published_at' => less_than('1955-01-01') }
              end
            ]
          end

          describe 'with empty data' do
            let(:data)     { [] }
            let(:expected) { data }

            it { expect(filtered_data).to be == expected }
          end

          wrap_context 'with data' do
            let(:expected) do
              data.reject do |item|
                item['author'] == 'J.R.R. Tolkien' &&
                  item['series'] == 'The Lord of the Rings' &&
                  item['published_at'] < '1955-01-01'
              end
            end

            it { expect(filtered_data).to be == expected }
          end
        end
      end
    end

    # Contract validating the behavior of a Disjunction scope implementation.
    module ShouldFilterDataByLogicalOrContract
      extend RSpec::SleepingKingStudios::Contract

      # @!method apply(example_group)
      #   Adds the contract to the example group.
      #
      #   @param example_group [RSpec::Core::ExampleGroup] the example group to
      #     which the contract is applied.
      contract do
        shared_context 'with data' do
          let(:data) do
            Cuprum::Collections::RSpec::Fixtures::BOOKS_FIXTURES
          end
        end

        context 'when the scope has no child scopes' do
          let(:scopes) { [] }

          describe 'with empty data' do
            let(:data) { [] }

            it { expect(filtered_data).to be == [] }
          end

          wrap_context 'with data' do
            it { expect(filtered_data).to be == [] }
          end
        end

        context 'when the scope has one child scope' do
          let(:scopes) do
            [
              build_scope({ 'author' => 'J.R.R. Tolkien' })
            ]
          end

          describe 'with empty data' do
            let(:data)     { [] }
            let(:expected) { data }

            it { expect(filtered_data).to be == expected }
          end

          wrap_context 'with data' do
            let(:expected) do
              data.select { |item| item['author'] == 'J.R.R. Tolkien' }
            end

            it { expect(filtered_data).to be == expected }
          end
        end

        context 'when the scope has many child scopes' do
          let(:scopes) do
            [
              build_scope({ 'author' => 'J.R.R. Tolkien' }),
              build_scope({ 'series' => 'The Lord of the Rings' }),
              build_scope do
                { 'published_at' => less_than('1955-01-01') }
              end
            ]
          end

          describe 'with empty data' do
            let(:data)     { [] }
            let(:expected) { data }

            it { expect(filtered_data).to be == expected }
          end

          wrap_context 'with data' do
            let(:expected) do
              data.select do |item|
                item['author'] == 'J.R.R. Tolkien' ||
                  item['series'] == 'The Lord of the Rings' ||
                  item['published_at'] < '1955-01-01'
              end
            end

            it { expect(filtered_data).to be == expected }
          end
        end
      end
    end
  end
end
