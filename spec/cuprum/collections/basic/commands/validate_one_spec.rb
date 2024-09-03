# frozen_string_literal: true

require 'stannum/constraints/presence'
require 'stannum/contracts/hash_contract'

require 'cuprum/collections/basic/commands/validate_one'
require 'cuprum/collections/rspec/deferred/commands/validate_one_examples'

require 'support/examples/basic/command_examples'

RSpec.describe Cuprum::Collections::Basic::Commands::ValidateOne do
  include Cuprum::Collections::RSpec::Deferred::Commands::ValidateOneExamples
  include Spec::Support::Examples::Basic::CommandExamples

  subject(:command) { described_class.new(collection:) }

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

  include_deferred 'with parameters for a basic command'

  include_deferred 'should implement the Basic::Command methods'

  include_deferred 'should implement the ValidateOne command',
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
    let(:collection_options) do
      super().merge(default_contract: expected_contract)
    end
    let(:invalid_default_attributes) { { title: 'Gideon the Ninth' } }
    let(:valid_default_attributes) do
      {
        title:  'Gideon the Ninth',
        author: 'Tamsyn Muir'
      }
    end

    include_deferred 'should implement the ValidateOne command',
      default_contract: true
  end
end
