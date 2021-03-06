# frozen_string_literal: true

require 'stannum/rspec/validate_parameter'

require 'cuprum/collections/constraints/ordering'
require 'cuprum/collections/rspec'
require 'cuprum/collections/rspec/querying_contract'

module Cuprum::Collections::RSpec
  # Contract validating the behavior of a FindMatching command implementation.
  FIND_MATCHING_COMMAND_CONTRACT = lambda do
    include Stannum::RSpec::Matchers

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

      it 'should validate the :envelope keyword' do
        expect(command)
          .to validate_parameter(:call, :envelope)
          .using_constraint(Stannum::Constraints::Boolean.new)
      end

      it 'should validate the :limit keyword' do
        expect(command)
          .to validate_parameter(:call, :limit)
          .with_value(Object.new)
          .using_constraint(Integer, required: false)
      end

      it 'should validate the :offset keyword' do
        expect(command)
          .to validate_parameter(:call, :offset)
          .with_value(Object.new)
          .using_constraint(Integer, required: false)
      end

      it 'should validate the :order keyword' do
        constraint = Cuprum::Collections::Constraints::Ordering.new

        expect(command)
          .to validate_parameter(:call, :order)
          .with_value(Object.new)
          .using_constraint(constraint, required: false)
      end

      it 'should validate the :scope keyword' do
        expect(command)
          .to validate_parameter(:call, :scope)
          .using_constraint(
            Stannum::Constraints::Type.new(query.class, optional: true)
          )
          .with_value(Object.new.freeze)
      end

      it 'should validate the :where keyword' do
        expect(command).to validate_parameter(:call, :where)
      end

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

      describe 'with envelope: true' do
        let(:options) { super().merge(envelope: true) }

        include_examples 'should return the wrapped items'

        include_contract Cuprum::Collections::RSpec::QUERYING_CONTRACT,
          block: lambda {
            include_examples 'should return the wrapped items'
          }
      end

      context 'when the collection has many items' do
        let(:data) { fixtures_data }

        include_examples 'should return the matching items'

        include_contract Cuprum::Collections::RSpec::QUERYING_CONTRACT,
          block: lambda {
            include_examples 'should return the matching items'
          }

        describe 'with envelope: true' do
          let(:options) { super().merge(envelope: true) }

          include_examples 'should return the wrapped items'

          include_contract Cuprum::Collections::RSpec::QUERYING_CONTRACT,
            block: lambda {
              include_examples 'should return the wrapped items'
            }
        end

        describe 'with scope: query' do
          let(:scope_filter) { -> { {} } }
          let(:options)      { super().merge(scope: scope) }

          describe 'with a scope that does not match any values' do
            let(:scope_filter)  { -> { { series: 'Mistborn' } } }
            let(:matching_data) { [] }

            include_examples 'should return the matching items'
          end

          describe 'with a scope that matches some values' do
            let(:scope_filter) { -> { { series: nil } } }
            let(:matching_data) do
              super().select { |item| item['series'].nil? }
            end

            include_examples 'should return the matching items'

            describe 'with a where filter' do
              let(:filter)  { -> { { author: 'Ursula K. LeGuin' } } }
              let(:options) { super().merge(where: filter) }
              let(:matching_data) do
                super().select { |item| item['author'] == 'Ursula K. LeGuin' }
              end

              include_examples 'should return the matching items'
            end
          end

          describe 'with a scope that matches all values' do
            let(:scope_filter) { -> { { id: not_equal(nil) } } }

            include_examples 'should return the matching items'

            describe 'with a where filter' do
              let(:filter)  { -> { { author: 'Ursula K. LeGuin' } } }
              let(:options) { super().merge(where: filter) }
              let(:matching_data) do
                super().select { |item| item['author'] == 'Ursula K. LeGuin' }
              end

              include_examples 'should return the matching items'
            end
          end
        end
      end
    end
  end
end
