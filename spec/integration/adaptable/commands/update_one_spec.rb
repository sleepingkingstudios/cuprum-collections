# frozen_string_literal: true

require 'bronze/rspec/deferred/command_examples'
require 'bronze/rspec/deferred/commands/update_one_examples'

require 'support/adaptable/commands/update_one'
require 'support/examples/adaptable/command_examples'

RSpec.describe Spec::Support::Adaptable::Commands::UpdateOne do
  include Bronze::RSpec::Deferred::CommandExamples
  include Bronze::RSpec::Deferred::Commands::UpdateOneExamples
  include Spec::Support::Examples::Adaptable::CommandExamples

  subject(:command) { described_class.new(collection:) }

  let(:attributes) do
    {
      id:     0,
      title:  'Gideon the Ninth',
      author: 'Tamsyn Muir'
    }
  end
  let(:entity) do
    Spec::BookEntity.new(**attributes)
  end
  let(:expected_data) do
    Spec::BookEntity.new(**matching_data)
  end

  include_deferred 'with parameters for an adaptable collection'

  include_deferred 'should implement the Bronze::Commands::Base methods'

  include_deferred 'should implement the UpdateOne command'
end
