# frozen_string_literal: true

require 'cuprum/collections/rspec/contracts/query_contracts'
require 'cuprum/collections/rspec/deferred/command_examples'
require 'cuprum/collections/rspec/deferred/commands'

module Cuprum::Collections::RSpec::Deferred::Commands
  # Namespace for deferred example groups for validating FindMatching commands.
  module FindMatchingExamples
    include RSpec::SleepingKingStudios::Deferred::Provider

    deferred_examples 'should implement the FindMatching command' do
      describe '#call' do
        include Cuprum::Collections::RSpec::Contracts::QueryContracts
        include Cuprum::Collections::RSpec::Deferred::CommandExamples

        shared_examples 'should return the matching items' do
          it { expect(result).to be_a_passing_result }

          it { expect(result.value).to be_a Enumerator }

          it { expect(result.value.to_a).to be == expected_data }
        end

        shared_examples 'should return the wrapped items' do
          it { expect(result).to be_a_passing_result }

          it { expect(result.value).to be_a Hash }

          it { expect(result.value.keys).to be == [collection.name] }

          it { expect(result.value[collection.name]).to be == expected_data }
        end

        let(:filter) { nil }
        let(:limit)  { nil }
        let(:offset) { nil }
        let(:order)  { nil }
        let(:options) do
          opts = {}

          opts[:limit]  = limit  if limit
          opts[:offset] = offset if offset
          opts[:order]  = order  if order
          opts[:where]  = filter unless filter.nil? || filter.is_a?(Proc)

          opts
        end
        let(:block)  { filter.is_a?(Proc) ? filter : nil }
        let(:result) { command.call(**options, &block) }
        let(:data)   { [] }
        let(:filtered_data) do
          defined?(super()) ? super() : data
        end
        let(:matching_data) do
          defined?(super()) ? super() : filtered_data
        end
        let(:expected_data) do
          defined?(super()) ? super() : matching_data
        end

        def call_command
          command.call(**options, &block)
        end

        describe 'with an invalid envelope value' do
          let(:options) { super().merge(envelope: Object.new.freeze) }

          include_deferred 'should validate the parameter',
            :envelope,
            'sleeping_king_studios.tools.assertions.boolean'
        end

        describe 'with an invalid limit value' do
          let(:options) { super().merge(limit: Object.new.freeze) }

          include_deferred 'should validate the parameter',
            :limit,
            'sleeping_king_studios.tools.assertions.instance_of',
            expected: Integer
        end

        describe 'with an invalid offset value' do
          let(:options) { super().merge(offset: Object.new.freeze) }

          include_deferred 'should validate the parameter',
            :offset,
            'sleeping_king_studios.tools.assertions.instance_of',
            expected: Integer
        end

        describe 'with an invalid order value' do
          let(:options) { super().merge(order: Object.new.freeze) }

          include_deferred 'should validate the parameter',
            :order,
            message: 'order is not a valid sort order'
        end

        describe 'with an invalid where value' do
          let(:options) { super().merge(where: Object.new.freeze) }

          include_deferred 'should validate the parameter',
            :where,
            message: 'where is not a scope or query hash'
        end

        describe 'with an invalid filter block' do
          let(:block) { -> {} }
          let(:expected_error) do
            an_instance_of(Cuprum::Collections::Errors::InvalidQuery)
          end

          it 'should return a failing result' do
            expect(result).to be_a_failing_result.with_error(expected_error)
          end
        end

        include_examples 'should return the matching items'

        describe 'with envelope: true' do
          let(:options) { super().merge(envelope: true) }

          include_examples 'should return the wrapped items'
        end

        context 'when the collection has many items' do
          let(:data) { fixtures_data }

          include_contract 'should query the collection' do
            include_examples 'should return the matching items'

            describe 'with envelope: true' do
              let(:options) { super().merge(envelope: true) }

              include_examples 'should return the wrapped items'
            end
          end
        end
      end
    end
  end
end
