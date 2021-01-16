# frozen_string_literal: true

require 'cuprum/collections/reference/commands/filter'
require 'cuprum/collections/rspec/filter_command_contract'
require 'cuprum/collections/rspec/fixtures'

require 'support/examples/command_examples'

RSpec.describe Cuprum::Collections::Reference::Commands::Filter do
  include Spec::Support::Examples::CommandExamples

  shared_context 'when the collection has many items' do
    let(:data) { Cuprum::Collections::RSpec::BOOKS_FIXTURES }
  end

  subject(:command) { described_class.new(data) }

  let(:data) { [] }

  describe '.new' do
    it { expect(described_class).to respond_to(:new).with(1).argument }
  end

  include_contract Cuprum::Collections::RSpec::FILTER_COMMAND_CONTRACT

  describe '#data' do
    include_examples 'should have reader', :data, -> { data }

    wrap_context 'when the collection has many items' do
      it { expect(command.data).to be == data }
    end
  end
end
