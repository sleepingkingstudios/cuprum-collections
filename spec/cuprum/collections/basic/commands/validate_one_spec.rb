# frozen_string_literal: true

require 'stannum/constraints/presence'
require 'stannum/contracts/hash_contract'

require 'cuprum/collections/basic/commands/validate_one'
require 'cuprum/collections/basic/rspec/command_contract'
require 'cuprum/collections/rspec/validate_one_command_contract'

RSpec.describe Cuprum::Collections::Basic::Commands::ValidateOne do
  subject(:command) do
    described_class.new(
      collection_name: collection_name,
      data:            data,
      **constructor_options
    )
  end

  let(:collection_name)     { 'books' }
  let(:data)                { [] }
  let(:constructor_options) { {} }
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
  let(:entity_type) do
    Stannum::Constraints::Types::HashWithStringKeys.new
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

  include_contract Cuprum::Collections::Basic::RSpec::COMMAND_CONTRACT

  include_contract Cuprum::Collections::RSpec::VALIDATE_ONE_COMMAND_CONTRACT,
    default_contract: false

  context 'when the collection has a default contract' do # rubocop:disable RSpec/EmptyExampleGroup
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
        author: 'Tammsyn Muir'
      }
    end

    include_contract Cuprum::Collections::RSpec::VALIDATE_ONE_COMMAND_CONTRACT,
      default_contract: true
  end
end
