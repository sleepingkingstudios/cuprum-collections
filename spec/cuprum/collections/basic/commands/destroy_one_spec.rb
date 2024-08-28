# frozen_string_literal: true

require 'cuprum/collections/basic/commands/destroy_one'
require 'cuprum/collections/rspec/contracts/command_contracts'

require 'support/examples/basic/command_examples'

RSpec.describe Cuprum::Collections::Basic::Commands::DestroyOne do
  include Cuprum::Collections::RSpec::Contracts::CommandContracts
  include Spec::Support::Examples::Basic::CommandExamples

  subject(:command) { described_class.new(collection:) }

  include_deferred 'with parameters for a basic command'

  include_deferred 'should implement the Basic::Command methods'

  include_contract 'should be a destroy one command'

  wrap_deferred 'with a collection with a custom primary key' do
    include_contract 'should be a destroy one command'
  end
end
