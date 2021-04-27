# frozen_string_literal: true

require 'cuprum/collections/basic/commands/build_one'
require 'cuprum/collections/basic/rspec/command_contract'
require 'cuprum/collections/rspec/build_one_command_contract'

require 'support/examples/basic_command_examples'

RSpec.describe Cuprum::Collections::Basic::Commands::BuildOne do
  include Spec::Support::Examples::BasicCommandExamples

  include_context 'with parameters for a basic contract'

  subject(:command) do
    described_class.new(
      collection_name: collection_name,
      data:            data,
      **constructor_options
    )
  end

  let(:expected_value) do
    SleepingKingStudios::Tools::HashTools
      .instance
      .convert_keys_to_strings(expected_attributes)
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

  include_contract Cuprum::Collections::RSpec::BUILD_ONE_COMMAND_CONTRACT,
    allow_extra_attributes: true
end
