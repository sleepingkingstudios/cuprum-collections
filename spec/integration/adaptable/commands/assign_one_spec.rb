# frozen_string_literal: true

require 'cuprum/collections/rspec/deferred/commands/assign_one_examples'

require 'support/adaptable/commands/assign_one'
require 'support/examples/adaptable/command_examples'

RSpec.describe Spec::Support::Adaptable::Commands::AssignOne do
  include Cuprum::Collections::RSpec::Deferred::CommandExamples
  include Cuprum::Collections::RSpec::Deferred::Commands::AssignOneExamples
  include Spec::Support::Examples::Adaptable::CommandExamples

  subject(:command) { described_class.new(collection:) }

  let(:initial_attributes) { {} }
  let(:entity)             { Spec::BookEntity.new(**initial_attributes) }
  let(:expected_value) do
    Spec::BookEntity.new(**expected_attributes)
  end
  let(:valid_attributes) do
    Spec::BookEntity.attributes.keys
  end

  include_deferred 'with parameters for an adaptable collection'

  include_deferred 'should implement the CollectionCommand methods'

  include_deferred 'should implement the AssignOne command',
    allow_extra_attributes: false
end
