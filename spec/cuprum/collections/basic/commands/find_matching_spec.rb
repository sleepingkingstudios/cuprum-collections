# frozen_string_literal: true

require 'cuprum/collections/basic/commands/find_matching'
require 'cuprum/collections/basic/rspec/command_contract'
require 'cuprum/collections/rspec/find_matching_command_contract'

require 'support/examples/basic_command_examples'

RSpec.describe Cuprum::Collections::Basic::Commands::FindMatching do
  include Spec::Support::Examples::BasicCommandExamples

  include_context 'with parameters for a basic contract'

  subject(:command) do
    described_class.new(
      collection_name: collection_name,
      data:            data,
      **constructor_options
    )
  end

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to respond_to(:new)
        .with(0).arguments
        .and_keywords(:collection_name, :data)
        .and_any_keywords
    end
  end

  include_contract Cuprum::Collections::Basic::RSpec::COMMAND_CONTRACT

  include_contract Cuprum::Collections::RSpec::FIND_MATCHING_COMMAND_CONTRACT
end
