# frozen_string_literal: true

require 'bronze/scopes/criteria_scope'
require 'bronze/rspec/deferred/scopes/criteria_examples'

RSpec.describe Bronze::Scopes::CriteriaScope do
  include Bronze::RSpec::Deferred::Scopes::CriteriaExamples

  subject(:scope) do
    described_class.new(criteria:, **constructor_options)
  end

  let(:criteria)            { [] }
  let(:constructor_options) { {} }

  include_deferred 'should implement the CriteriaScope methods', abstract: true
end
