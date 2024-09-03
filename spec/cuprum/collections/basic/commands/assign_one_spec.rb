# frozen_string_literal: true

require 'cuprum/collections/basic/commands/assign_one'
require 'cuprum/collections/rspec/deferred/commands/assign_one_examples'

require 'support/examples/basic/command_examples'

RSpec.describe Cuprum::Collections::Basic::Commands::AssignOne do
  include Cuprum::Collections::RSpec::Deferred::Commands::AssignOneExamples
  include Spec::Support::Examples::Basic::CommandExamples

  subject(:command) { described_class.new(collection:) }

  let(:initial_attributes) { {} }
  let(:entity)             { initial_attributes }
  let(:expected_value) do
    SleepingKingStudios::Tools::HashTools
      .instance
      .convert_keys_to_strings(expected_attributes)
  end

  include_deferred 'with parameters for a basic command'

  include_deferred 'should implement the Basic::Command methods'

  include_deferred 'should implement the AssignOne command',
    allow_extra_attributes: true
end
