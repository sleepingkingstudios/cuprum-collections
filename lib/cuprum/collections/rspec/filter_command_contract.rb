# frozen_string_literal: true

require 'cuprum/collections/constraints/ordering'
require 'cuprum/collections/rspec'
require 'cuprum/collections/rspec/fixtures'
require 'cuprum/collections/rspec/querying_contract'

module Cuprum::Collections::RSpec
  # Contract validating the behavior of a Filter command implementation.
  FILTER_COMMAND_CONTRACT = lambda do
    describe '#call' do
      shared_examples 'should return the matching items' do
        it { expect(result).to be_a_passing_result }

        it { expect(result.value).to be_a Enumerator }

        it { expect(result.value.to_a).to be == expected_data }
      end

      shared_examples 'should return the wrapped items' do
        it { expect(result).to be_a_passing_result }

        it { expect(result.value).to be_a Hash }

        it { expect(result.value.keys).to be == [collection_name] }

        it { expect(result.value[collection_name]).to be == expected_data }
      end

      include_contract Cuprum::Collections::RSpec::QUERYING_CONTEXTS

      let(:options) do
        opts = {}

        opts[:limit]  = limit  if limit
        opts[:offset] = offset if offset
        opts[:order]  = order  if order
        opts[:where]  = filter unless filter.nil? || filter.is_a?(Proc)

        opts
      end
      let(:block)         { filter.is_a?(Proc) ? filter : nil }
      let(:result)        { command.call(**options, &block) }
      let(:data)          { [] }
      let(:matching_data) { data }
      let(:expected_data) do
        defined?(super()) ? super() : matching_data
      end

      include_examples 'should validate the keyword',
        :limit,
        type:     Integer,
        optional: true

      include_examples 'should validate the keyword',
        :offset,
        type:     Integer,
        optional: true

      include_examples 'should validate the keyword',
        :order,
        type:     Cuprum::Collections::Constraints::Ordering.new,
        optional: true

      include_examples 'should return the matching items'

      include_contract Cuprum::Collections::RSpec::QUERYING_CONTRACT,
        block: lambda {
          include_examples 'should return the matching items'
        }

      describe 'with an invalid filter block' do
        let(:block) { -> { nil } }
        let(:expected_error) do
          an_instance_of(Cuprum::Collections::Errors::InvalidQuery)
        end

        it 'should return a failing result' do
          expect(result).to be_a_failing_result.with_error(expected_error)
        end
      end

      context 'when initialized with envelope: true' do
        let(:constructor_options) { super().merge(envelope: true) }

        include_examples 'should return the wrapped items'

        include_contract Cuprum::Collections::RSpec::QUERYING_CONTRACT,
          block: lambda {
            include_examples 'should return the wrapped items'
          }
      end

      context 'when the collection has many items' do
        let(:data) { Cuprum::Collections::RSpec::BOOKS_FIXTURES }

        include_examples 'should return the matching items'

        include_contract Cuprum::Collections::RSpec::QUERYING_CONTRACT,
          block: lambda {
            include_examples 'should return the matching items'
          }

        context 'when initialized with envelope: true' do
          let(:constructor_options) { super().merge(envelope: true) }

          include_examples 'should return the wrapped items'

          include_contract Cuprum::Collections::RSpec::QUERYING_CONTRACT,
            block: lambda {
              include_examples 'should return the wrapped items'
            }
        end
      end
    end
  end
end
