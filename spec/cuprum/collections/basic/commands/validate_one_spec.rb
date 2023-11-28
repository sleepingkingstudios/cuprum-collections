# frozen_string_literal: true

require 'stannum/constraints/presence'
require 'stannum/contracts/hash_contract'

require 'cuprum/collections/basic/commands/validate_one'
require 'cuprum/collections/rspec/contracts/basic/command_contracts'
require 'cuprum/collections/rspec/contracts/command_contracts'

RSpec.describe Cuprum::Collections::Basic::Commands::ValidateOne do
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

  let(:contract) do
    Stannum::Contracts::HashContract.new do
      key 'title', Stannum::Constraints::Presence.new
    end
  end
  let(:invalid_attributes) { {} }
  let(:valid_attributes)   { { title: 'Gideon the Ninth' } }
  let(:entity) do
    tools.hash_tools.convert_keys_to_strings(attributes)
  end

  def tools
    SleepingKingStudios::Tools::Toolbelt.instance
  end

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to respond_to(:new)
        .with(0).arguments
        .and_keywords(:collection_name, :data, :default_contract)
        .and_any_keywords
    end
  end

  include_contract 'should be a basic command'

  include_contract 'should be a validate one command',
    default_contract: false

  context 'when the collection has a default contract' do
    let(:expected_contract) do
      Stannum::Contracts::HashContract.new do
        key 'title',  Stannum::Constraints::Presence.new
        key 'author', Stannum::Constraints::Presence.new
      end
    end
    let(:expected_errors) do
      expected_contract.errors_for(entity)
    end
    let(:constructor_options) do
      super().merge(default_contract: expected_contract)
    end
    let(:invalid_default_attributes) { { title: 'Gideon the Ninth' } }
    let(:valid_default_attributes) do
      {
        title:  'Gideon the Ninth',
        author: 'Tamsyn Muir'
      }
    end

    include_contract 'should be a validate one command',
      default_contract: true
  end
end
