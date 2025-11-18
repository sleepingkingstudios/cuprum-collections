# frozen_string_literal: true

require 'cuprum/collections/rspec/deferred/scopes/none_examples'
require 'cuprum/collections/scopes/base'
require 'cuprum/collections/scopes/none'

RSpec.describe Cuprum::Collections::Scopes::None do
  include Cuprum::Collections::RSpec::Deferred::Scopes::NoneExamples

  let(:described_class) { Spec::ExampleScope }

  example_class 'Spec::ExampleScope', Cuprum::Collections::Scopes::Base \
  do |klass|
    klass.include Cuprum::Collections::Scopes::None # rubocop:disable RSpec/DescribedClass
  end

  include_deferred 'should implement the NoneScope methods', abstract: true
end
