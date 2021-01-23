# frozen_string_literal: true

require 'cuprum/collections/queries/parse'

RSpec.describe Cuprum::Collections::Queries::Parse do
  subject(:command) { described_class.new }

  describe '.new' do
    it { expect(described_class).to respond_to(:new).with(0).arguments }
  end

  describe '#call' do
    let(:arguments) { %w[ichi ni san] }
    let(:block)     { -> {} }
    let(:keywords)  { { one: 1, two: 2, three: 3 } }
    let(:parameters) do
      {
        arguments: arguments,
        block:     block,
        keywords:  keywords
      }
    end
    let(:criteria) { [[:title, :eq, 'Binti']] }
    let(:strategy_command) do
      Cuprum::Collections::Queries::ParseStrategy.new
    end
    let(:selected_strategy) { instance_double(Cuprum::Command, call: criteria) }

    before(:example) do
      allow(Cuprum::Collections::Queries::ParseStrategy)
        .to receive(:new)
        .and_return(strategy_command)

      allow(strategy_command).to receive(:call).and_return(selected_strategy)
    end

    it 'should determine the parsing strategy' do
      command.call(**parameters)

      expect(strategy_command).to have_received(:call).with(
        strategy: nil,
        **parameters
      )
    end

    it 'should call the selected strategy command' do
      command.call(**parameters)

      expect(selected_strategy).to have_received(:call).with(**parameters)
    end

    it 'should return a passing result with the parsed criteria' do
      expect(command.call(**parameters))
        .to be_a_passing_result
        .with_value(criteria)
    end

    describe 'with strategy: value' do
      let(:strategy) { :block }

      it 'should determine the parsing strategy' do
        command.call(strategy: strategy, **parameters)

        expect(strategy_command).to have_received(:call).with(
          strategy: strategy,
          **parameters
        )
      end

      it 'should call the selected strategy command' do
        command.call(strategy: strategy, **parameters)

        expect(selected_strategy).to have_received(:call).with(**parameters)
      end

      it 'should return a passing result with the parsed criteria' do
        expect(command.call(strategy: strategy, **parameters))
          .to be_a_passing_result
          .with_value(criteria)
      end
    end

    describe 'with strategy: :unsafe' do
      let(:arguments) { [criteria] }

      it 'should not determine the parsing strategy' do
        command.call(strategy: :unsafe, **parameters)

        expect(strategy_command).not_to have_received(:call)
      end

      it 'should not call a strategy command' do
        command.call(strategy: :unsafe, **parameters)

        expect(selected_strategy).not_to have_received(:call)
      end

      it 'should return a passing result with the parsed criteria' do
        expect(command.call(strategy: :unsafe, **parameters))
          .to be_a_passing_result
          .with_value(criteria)
      end
    end
  end
end
