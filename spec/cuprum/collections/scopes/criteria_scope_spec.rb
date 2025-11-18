# frozen_string_literal: true

require 'cuprum/collections/scopes/criteria_scope'
require 'cuprum/collections/rspec/deferred/scopes/criteria_scope_examples'

RSpec.describe Cuprum::Collections::Scopes::CriteriaScope do
  include Cuprum::Collections::RSpec::Deferred::Scopes::CriteriaScopeExamples

  subject(:scope) do
    described_class.new(criteria:, **constructor_options)
  end

  let(:criteria)            { [] }
  let(:constructor_options) { {} }

  include_deferred 'should be a CriteriaScope', abstract: true
end
