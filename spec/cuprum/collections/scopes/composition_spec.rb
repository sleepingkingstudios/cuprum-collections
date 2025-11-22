# frozen_string_literal: true

require 'cuprum/collections/rspec/deferred/scope_examples'
require 'cuprum/collections/scopes/base'
require 'cuprum/collections/scopes/composition'

RSpec.describe Cuprum::Collections::Scopes::Composition do
  include Cuprum::Collections::RSpec::Deferred::ScopeExamples

  subject(:scope) { described_class.new }

  let(:described_class) { Spec::ExampleScope }

  example_class 'Spec::ExampleScope', Cuprum::Collections::Scopes::Base

  include_deferred 'should compose scopes'
end
