# frozen_string_literal: true

require 'cuprum/collections/rspec/deferred/scopes/none_scope_examples'
require 'cuprum/collections/scopes/base'
require 'cuprum/collections/scopes/none'

RSpec.describe Cuprum::Collections::Scopes::None do
  include Cuprum::Collections::RSpec::Deferred::Scopes::NoneScopeExamples

  let(:described_class) { Spec::ExampleScope }

  example_class 'Spec::ExampleScope', Cuprum::Collections::Scopes::Base \
  do |klass|
    klass.include Cuprum::Collections::Scopes::None # rubocop:disable RSpec/DescribedClass
  end

  include_deferred 'should be a NoneScope', abstract: true
end
