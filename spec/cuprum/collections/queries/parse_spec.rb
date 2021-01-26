# frozen_string_literal: true

require 'cuprum/collections/queries/parse'

RSpec.describe Cuprum::Collections::Queries::Parse do
  subject(:command) { described_class.new }

  describe '.new' do
    it { expect(described_class).to respond_to(:new).with(0).arguments }
  end

  describe '#call' do
    let(:filter)   { { title: 'Binti' } }
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
      command.call(where: filter)

      expect(strategy_command).to have_received(:call).with(
        strategy: nil,
        where:    filter
      )
    end

    it 'should call the selected strategy command' do
      command.call(where: filter)

      expect(selected_strategy).to have_received(:call).with(where: filter)
    end

    it 'should return a passing result with the parsed criteria' do
      expect(command.call(where: filter))
        .to be_a_passing_result
        .with_value(criteria)
    end

    describe 'with strategy: value' do
      let(:strategy) { :block }

      it 'should determine the parsing strategy' do
        command.call(strategy: strategy, where: filter)

        expect(strategy_command).to have_received(:call).with(
          strategy: strategy,
          where:    filter
        )
      end

      it 'should call the selected strategy command' do
        command.call(strategy: strategy, where: filter)

        expect(selected_strategy).to have_received(:call).with(where: filter)
      end

      it 'should return a passing result with the parsed criteria' do
        expect(command.call(strategy: strategy, where: filter))
          .to be_a_passing_result
          .with_value(criteria)
      end
    end
  end
end
