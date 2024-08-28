# frozen_string_literal: true

require 'cuprum/collections/basic/commands/build_one'
require 'cuprum/collections/rspec/contracts/command_contracts'

require 'support/examples/basic/command_examples'

RSpec.describe Cuprum::Collections::Basic::Commands::BuildOne do
  include Cuprum::Collections::RSpec::Contracts::CommandContracts
  include Spec::Support::Examples::Basic::CommandExamples

  subject(:command) { described_class.new(collection:) }

  let(:expected_value) do
    SleepingKingStudios::Tools::HashTools
      .instance
      .convert_keys_to_strings(expected_attributes)
  end

  include_deferred 'with parameters for a basic command'

  include_deferred 'should implement the Basic::Command methods'

  include_contract 'should be a build one command',
    allow_extra_attributes: true
end
