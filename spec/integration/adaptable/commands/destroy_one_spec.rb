# frozen_string_literal: true

require 'bronze/rspec/deferred/command_examples'
require 'bronze/rspec/deferred/commands/destroy_one_examples'

require 'support/adaptable/commands/destroy_one'
require 'support/examples/adaptable/command_examples'

RSpec.describe Spec::Support::Adaptable::Commands::DestroyOne do
  include Bronze::RSpec::Deferred::CommandExamples
  include Bronze::RSpec::Deferred::Commands::DestroyOneExamples
  include Spec::Support::Examples::Adaptable::CommandExamples

  subject(:command) { described_class.new(collection:) }

  let(:attributes) { {} }
  let(:entity)     { Spec::BookEntity.new(**attributes) }

  include_deferred 'with parameters for an adaptable collection'

  include_deferred 'should implement the Bronze::Commands::Base methods'

  include_deferred 'should implement the DestroyOne command'
end
