# frozen_string_literal: true

require 'bronze/collection_command'

RSpec.describe Bronze::CollectionCommand do
  it { expect(described_class).to be < Bronze::Commands::Base }

  describe '.inherited' do
    let(:tools) { SleepingKingStudios::Tools::Toolbelt.instance }

    before(:example) { allow(tools.core_tools).to receive(:deprecate) }

    it 'should print a deprecation warning' do # rubocop:disable RSpec/ExampleLength
      Class.new(described_class)

      expect(tools.core_tools)
        .to have_received(:deprecate)
        .with(
          'Bronze::CollectionCommand',
          'Use Bronze::Commands::Base instead.'
        )
    end
  end
end
