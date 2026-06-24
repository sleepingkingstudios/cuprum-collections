# frozen_string_literal: true

require 'bronze/basic/commands/find_matching'
require 'bronze/rspec/deferred/commands/find_matching_examples'

require 'support/examples/basic/command_examples'

RSpec.describe Bronze::Basic::Commands::FindMatching do
  include Bronze::RSpec::Deferred::Commands::FindMatchingExamples
  include Spec::Support::Examples::Basic::CommandExamples

  subject(:command) { described_class.new(collection:) }

  include_deferred 'with parameters for a basic command'

  include_deferred 'should implement the Basic::Command methods'

  include_deferred 'should implement the FindMatching command'
end
