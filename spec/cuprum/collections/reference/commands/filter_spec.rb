# frozen_string_literal: true

require 'cuprum/collections/reference/commands/filter'
require 'cuprum/collections/reference/rspec/command_contract'
require 'cuprum/collections/rspec/filter_command_contract'

require 'support/examples/command_examples'

RSpec.describe Cuprum::Collections::Reference::Commands::Filter do
  include Spec::Support::Examples::CommandExamples

  subject(:command) do
    described_class.new(
      collection_name: collection_name,
      data:            data,
      **constructor_options
    )
  end

  let(:collection_name)     { 'books' }
  let(:data)                { [] }
  let(:constructor_options) { {} }
  let(:expected_options)    { { envelope: false } }

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to respond_to(:new)
        .with(0).arguments
        .and_keywords(:collection_name, :data, :envelope)
        .and_any_keywords
    end
  end

  include_contract Cuprum::Collections::Reference::RSpec::COMMAND_CONTRACT

  include_contract Cuprum::Collections::RSpec::FILTER_COMMAND_CONTRACT
end
