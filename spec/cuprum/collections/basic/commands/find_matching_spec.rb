# frozen_string_literal: true

require 'cuprum/collections/basic/commands/find_matching'
require 'cuprum/collections/rspec/deferred/commands/find_matching_examples'

require 'support/examples/basic/command_examples'

RSpec.describe Cuprum::Collections::Basic::Commands::FindMatching do
  include Cuprum::Collections::RSpec::Deferred::Commands::FindMatchingExamples
  include Spec::Support::Examples::Basic::CommandExamples

  subject(:command) { described_class.new(collection:) }

  include_deferred 'with parameters for a basic command'

  include_deferred 'should implement the Basic::Command methods'

  include_deferred 'should implement the FindMatching command'
end
