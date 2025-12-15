# frozen_string_literal: true

require 'cuprum/collections/rspec/deferred/commands/find_many_examples'

require 'support/adaptable/commands/find_many'
require 'support/examples/adaptable/command_examples'

RSpec.describe Spec::Support::Adaptable::Commands::FindMany do
  include Cuprum::Collections::RSpec::Deferred::CommandExamples
  include Cuprum::Collections::RSpec::Deferred::Commands::FindManyExamples
  include Spec::Support::Examples::Adaptable::CommandExamples

  subject(:command) { described_class.new(collection:) }

  include_deferred 'with parameters for an adaptable collection'

  include_deferred 'should implement the CollectionCommand methods'

  include_deferred 'should implement the FindMany command'
end
