# frozen_string_literal: true

require 'cuprum/collections/rspec/deferred/commands/destroy_one_examples'

require 'support/adaptable/commands/destroy_one'
require 'support/examples/adaptable/command_examples'

RSpec.describe Spec::Support::Adaptable::Commands::DestroyOne do
  include Cuprum::Collections::RSpec::Deferred::CommandExamples
  include Cuprum::Collections::RSpec::Deferred::Commands::DestroyOneExamples
  include Spec::Support::Examples::Adaptable::CommandExamples

  subject(:command) { described_class.new(collection:) }

  let(:attributes) { {} }
  let(:entity)     { Spec::BookEntity.new(**attributes) }

  include_deferred 'with parameters for an adaptable collection'

  include_deferred 'should implement the CollectionCommand methods'

  include_deferred 'should implement the DestroyOne command'
end
