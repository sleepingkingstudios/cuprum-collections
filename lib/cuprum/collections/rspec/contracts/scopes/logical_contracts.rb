# frozen_string_literal: true

require 'cuprum/collections/rspec/contracts'
require 'cuprum/collections/rspec/contracts/scope_contracts'
require 'cuprum/collections/rspec/contracts/scopes/composition_contracts'
require 'cuprum/collections/rspec/fixtures'

module Cuprum::Collections::RSpec::Contracts::Scopes
  # Contracts for asserting on logical scope objects.
  module LogicalContracts
    include Cuprum::Collections::RSpec::Contracts::ScopeContracts
    include Cuprum::Collections::RSpec::Contracts::Scopes::CompositionContracts

    # Contract validating the behavior of a logical AND scope implementation.
    module ShouldBeAConjunctionScopeContract
      extend RSpec::SleepingKingStudios::Contract

      # @!method apply(example_group, abstract: false)
      #   Adds the contract to the example group.
      #
      #   @param example_group [RSpec::Core::ExampleGroup] the example group to
      #     which the contract is applied.
      #   @param abstract [Boolean] if true, the scope is abstract and does not
      #     define a #call implementation. Defaults to false.
      contract do |abstract: false|
        include_contract 'should be a container scope'

        include_contract 'should compose scopes for conjunction'

        describe '#call' do
          next if abstract

          include_contract 'should filter data by logical and'
        end

        describe '#type' do
          include_examples 'should define reader', :type, :conjunction
        end
      end
    end

    # Contract validating the behavior of a logical OR scope implementation.
    module ShouldBeADisjunctionScopeContract
      extend RSpec::SleepingKingStudios::Contract

      # @!method apply(example_group, abstract: false)
      #   Adds the contract to the example group.
      #
      #   @param example_group [RSpec::Core::ExampleGroup] the example group to
      #     which the contract is applied.
      #   @param abstract [Boolean] if true, the scope is abstract and does not
      #     define a #call implementation. Defaults to false.
      contract do |abstract: false|
        include_contract 'should be a container scope'

        include_contract 'should compose scopes for disjunction'

        describe '#call' do
          next if abstract

          include_contract 'should filter data by logical or'
        end

        describe '#type' do
          include_examples 'should define reader', :type, :disjunction
        end
      end
    end

    # Contract validating the behavior of a logical NAND scope implementation.
    module ShouldBeANegationScopeContract
      extend RSpec::SleepingKingStudios::Contract

      # @!method apply(example_group, abstract: false)
      #   Adds the contract to the example group.
      #
      #   @param example_group [RSpec::Core::ExampleGroup] the example group to
      #     which the contract is applied.
      #   @param abstract [Boolean] if true, the scope is abstract and does not
      #     define a #call implementation. Defaults to false.
      contract do |abstract: false|
        include_contract 'should be a container scope'

        describe '#call' do
          next if abstract

          include_contract 'should filter data by logical nand'
        end

        describe '#type' do
          include_examples 'should define reader', :type, :negation
        end
      end
    end

    # Contract validating the behavior of a Conjunction scope implementation.
    module ShouldFilterDataByLogicalAndContract
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
            let(:data)     { [] }
            let(:expected) { data }

            it { expect(filtered_data).to be == expected }
          end

          wrap_context 'with data' do
            let(:expected) { data }

            it { expect(filtered_data).to be == expected }
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
              data
                .select { |item| item['author'] == 'J.R.R. Tolkien' }
                .select { |item| item['series'] == 'The Lord of the Rings' }
                .select { |item| item['published_at'] < '1955-01-01' }
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
  end
end
