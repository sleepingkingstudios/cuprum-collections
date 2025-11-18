# frozen_string_literal: true

require 'cuprum/collections/rspec/deferred/scopes/builder_examples'

RSpec.describe Cuprum::Collections::Scopes::Builder do
  include Cuprum::Collections::RSpec::Deferred::Scopes::BuilderExamples

  subject(:builder) { described_class.instance }

  define_method :build_scope do
    Cuprum::Collections::Scopes::CriteriaScope.build({ 'ok' => true })
  end

  include_deferred 'should be a Scope builder',
    namespace: Cuprum::Collections::Scopes
end
