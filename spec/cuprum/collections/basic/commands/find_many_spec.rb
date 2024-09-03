# frozen_string_literal: true

require 'cuprum/collections/basic/commands/find_many'
require 'cuprum/collections/rspec/deferred/commands/find_many_examples'

require 'support/examples/basic/command_examples'

RSpec.describe Cuprum::Collections::Basic::Commands::FindMany do
  include Cuprum::Collections::RSpec::Deferred::Commands::FindManyExamples
  include Spec::Support::Examples::Basic::CommandExamples

  subject(:command) { described_class.new(collection:) }

  let(:data)        { [] }
  let(:mapped_data) { data }
  let(:query)       { Cuprum::Collections::Basic::Query.new(mapped_data) }

  include_deferred 'with parameters for a basic command'

  include_deferred 'should implement the Basic::Command methods'

  include_deferred 'should implement the FindMany command'

  wrap_deferred 'with a collection with a custom primary key' do
    include_deferred 'should implement the FindMany command'
  end
end
