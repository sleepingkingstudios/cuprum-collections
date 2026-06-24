# frozen_string_literal: true

require 'bronze/scopes/base'
require 'bronze/scopes/criteria'
require 'bronze/rspec/deferred/scopes/criteria_examples'

RSpec.describe Bronze::Scopes::Criteria do
  include Bronze::RSpec::Deferred::Scopes::CriteriaExamples

  subject(:scope) do
    described_class.new(criteria:, **constructor_options)
  end

  let(:described_class)     { Spec::ExampleScope }
  let(:constructor_options) { {} }

  example_class 'Spec::ExampleScope', Bronze::Scopes::Base do |klass|
    klass.include Bronze::Scopes::Criteria # rubocop:disable RSpec/DescribedClass
  end

  include_deferred 'should implement the CriteriaScope methods', abstract: true
end
