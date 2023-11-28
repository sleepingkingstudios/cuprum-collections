# frozen_string_literal: true

require 'cuprum/collections/basic/commands/find_matching'
require 'cuprum/collections/rspec/contracts/basic/command_contracts'
require 'cuprum/collections/rspec/contracts/command_contracts'

RSpec.describe Cuprum::Collections::Basic::Commands::FindMatching do
  include Cuprum::Collections::RSpec::Contracts::Basic::CommandContracts
  include Cuprum::Collections::RSpec::Contracts::CommandContracts

  with_contract 'with basic command contexts'

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

  include_contract 'should be a basic command'

  include_contract 'should be a find matching command'
end
