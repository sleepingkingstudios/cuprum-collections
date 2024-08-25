# frozen_string_literal: true

require 'stannum/constraints/types/hash_with_string_keys'

require 'cuprum/collections/basic/commands/assign_one'
require 'cuprum/collections/rspec/contracts/basic/command_contracts'
require 'cuprum/collections/rspec/contracts/command_contracts'

RSpec.describe Cuprum::Collections::Basic::Commands::AssignOne do
  include Cuprum::Collections::RSpec::Contracts::Basic::CommandContracts
  include Cuprum::Collections::RSpec::Contracts::CommandContracts

  with_contract 'with basic command contexts'

  include_context 'with parameters for a basic contract'

  subject(:command) do
    described_class.new(
      collection_name:,
      data:,
      **constructor_options
    )
  end

  let(:initial_attributes) { {} }
  let(:entity)             { initial_attributes }
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

  include_contract 'should be a basic command'

  include_contract 'should be an assign one command',
    allow_extra_attributes: true
end
