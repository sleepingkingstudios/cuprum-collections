# frozen_string_literal: true

require 'cuprum/collections/rspec/deferred/commands/validate_one_examples'
require 'stannum/contracts/map_contract'

require 'support/adaptable/commands/validate_one'
require 'support/examples/adaptable/command_examples'

RSpec.describe Spec::Support::Adaptable::Commands::ValidateOne do
  include Cuprum::Collections::RSpec::Deferred::CommandExamples
  include Cuprum::Collections::RSpec::Deferred::Commands::ValidateOneExamples
  include Spec::Support::Examples::Adaptable::CommandExamples

  subject(:command) { described_class.new(collection:) }

  let(:contract) do
    Stannum::Contract.new do
      property 'title', Stannum::Constraints::Presence.new
    end
  end
  let(:invalid_attributes) { {} }
  let(:valid_attributes)   { { title: 'Gideon the Ninth' } }
  let(:attributes)         { {} }
  let(:entity)             { Spec::BookEntity.new(**attributes) }
  let(:invalid_default_attributes) do
    {
      title:  'Gideon the Ninth',
      series: 'The Locked Tomb'
    }
  end
  let(:valid_default_attributes) do
    {
      id:     0,
      title:  'Gideon the Ninth',
      author: 'Tamsyn Muir'
    }
  end
  let(:expected_errors) do
    Stannum::Errors.new.tap do |err|
      err[:id]
        .add(Stannum::Constraints::Type::TYPE, required: true, type: Integer)
      err[:author]
        .add(Stannum::Constraints::Type::TYPE, required: true, type: String)
    end
  end

  include_deferred 'with parameters for an adaptable collection'

  include_deferred 'should implement the CollectionCommand methods'

  include_deferred 'should implement the ValidateOne command',
    default_contract: true
end
