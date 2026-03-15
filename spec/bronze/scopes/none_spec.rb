# frozen_string_literal: true

require 'bronze/scopes/base'
require 'bronze/scopes/none'
require 'cuprum/collections/rspec/deferred/scopes/none_examples'

RSpec.describe Bronze::Scopes::None do
  include Cuprum::Collections::RSpec::Deferred::Scopes::NoneExamples

  let(:described_class) { Spec::ExampleScope }

  example_class 'Spec::ExampleScope', Bronze::Scopes::Base do |klass|
    klass.include Bronze::Scopes::None # rubocop:disable RSpec/DescribedClass
  end

  include_deferred 'should implement the NoneScope methods', abstract: true
end
