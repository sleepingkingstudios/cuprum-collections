# frozen_string_literal: true

require 'cuprum/collections/basic/commands/insert_one'
require 'cuprum/collections/rspec/contracts/command_contracts'

require 'support/examples/basic/command_examples'

RSpec.describe Cuprum::Collections::Basic::Commands::InsertOne do
  include Cuprum::Collections::RSpec::Contracts::CommandContracts
  include Spec::Support::Examples::Basic::CommandExamples

  subject(:command) { described_class.new(collection:) }

  let(:attributes) do
    {
      id:     0,
      title:  'Gideon the Ninth',
      author: 'Tamsyn Muir'
    }
  end
  let(:entity) do
    tools.hash_tools.convert_keys_to_strings(attributes)
  end
  let(:expected_data) do
    tools.hash_tools.convert_keys_to_strings(matching_data)
  end

  def tools
    SleepingKingStudios::Tools::Toolbelt.instance
  end

  include_deferred 'with parameters for a basic command'

  include_deferred 'should implement the Basic::Command methods'

  include_contract 'should be an insert one command'

  wrap_deferred 'with a collection with a custom primary key' do
    let(:attributes) do
      super()
        .tap { |hsh| hsh.delete(:id) }
        .merge(uuid: '00000000-0000-0000-0000-000000000000')
    end

    include_contract 'should be an insert one command'
  end
end
