# frozen_string_literal: true

require 'bronze/rspec/deferred/command_examples'
require 'bronze/rspec/deferred/commands/find_matching_examples'

require 'support/adaptable/commands/find_matching'
require 'support/examples/adaptable/command_examples'

RSpec.describe Spec::Support::Adaptable::Commands::FindMatching do
  include Bronze::RSpec::Deferred::CommandExamples
  include Bronze::RSpec::Deferred::Commands::FindMatchingExamples
  include Spec::Support::Examples::Adaptable::CommandExamples

  subject(:command) { described_class.new(collection:) }

  include_deferred 'with parameters for an adaptable collection'

  include_deferred 'should implement the Bronze::Commands::Base methods'

  include_deferred 'should implement the FindMatching command'
end
