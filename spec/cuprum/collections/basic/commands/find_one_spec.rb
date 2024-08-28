# frozen_string_literal: true

require 'cuprum/collections/basic/commands/find_one'
require 'cuprum/collections/rspec/contracts/command_contracts'

require 'support/examples/basic/command_examples'

RSpec.describe Cuprum::Collections::Basic::Commands::FindOne do
  include Cuprum::Collections::RSpec::Contracts::CommandContracts
  include Spec::Support::Examples::Basic::CommandExamples

  subject(:command) { described_class.new(collection:) }

  let(:initial_attributes) { {} }
  let(:entity)             { initial_attributes }

  include_deferred 'with parameters for a basic command'

  include_deferred 'should implement the Basic::Command methods'

  include_contract 'should be a find one command'

  wrap_deferred 'with a collection with a custom primary key' do
    include_contract 'should be a find one command'
  end
end
