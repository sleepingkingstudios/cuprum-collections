# frozen_string_literal: true

require 'bronze/scopes/base'
require 'bronze/scopes/composition'
require 'bronze/rspec/deferred/scope_examples'

RSpec.describe Bronze::Scopes::Composition do
  include Bronze::RSpec::Deferred::ScopeExamples

  subject(:scope) { described_class.new }

  let(:described_class) { Spec::ExampleScope }

  example_class 'Spec::ExampleScope', Bronze::Scopes::Base

  include_deferred 'should compose scopes'
end
