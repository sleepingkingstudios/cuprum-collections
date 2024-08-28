# frozen_string_literal: true

require 'cuprum/collections/basic/command'

require 'support/examples/basic/command_examples'

RSpec.describe Cuprum::Collections::Basic::Command do
  include Spec::Support::Examples::Basic::CommandExamples

  subject(:command) { described_class.new(collection:) }

  include_deferred 'with parameters for a basic command'

  include_deferred 'should implement the Basic::Command methods'

  describe '#call' do
    it 'should define the method' do
      expect(command)
        .to respond_to(:call)
        .with_unlimited_arguments
        .and_any_keywords
    end

    it 'should return a failing result with not implemented error' do
      expect(command.call)
        .to be_a_failing_result
        .with_error(an_instance_of Cuprum::Errors::CommandNotImplemented)
    end
  end
end
