# frozen_string_literal: true

require 'bronze/basic/commands/destroy_one'
require 'bronze/rspec/deferred/commands/destroy_one_examples'

require 'support/examples/basic/command_examples'

RSpec.describe Bronze::Basic::Commands::DestroyOne do
  include Bronze::RSpec::Deferred::Commands::DestroyOneExamples
  include Spec::Support::Examples::Basic::CommandExamples

  subject(:command) { described_class.new(collection:) }

  include_deferred 'with parameters for a basic command'

  include_deferred 'should implement the Basic::Command methods'

  include_deferred 'should implement the DestroyOne command'

  wrap_deferred 'with a collection with a custom primary key' do
    include_deferred 'should implement the DestroyOne command'
  end
end
