# frozen_string_literal: true

require 'bronze/scopes/all'
require 'bronze/scopes/base'
require 'cuprum/collections/rspec/deferred/scopes/all_examples'

RSpec.describe Bronze::Scopes::All do
  include Cuprum::Collections::RSpec::Deferred::Scopes::AllExamples

  let(:described_class) { Spec::ExampleScope }

  example_class 'Spec::ExampleScope', Bronze::Scopes::Base do |klass|
    klass.include Bronze::Scopes::All # rubocop:disable RSpec/DescribedClass
  end

  include_deferred 'should implement the AllScope methods', abstract: true
end
