# frozen_string_literal: true

require 'cuprum/collections/basic/scopes/builder'
require 'cuprum/collections/rspec/deferred/scopes/builder_examples'
require 'cuprum/collections/scopes/criteria_scope'

RSpec.describe Cuprum::Collections::Basic::Scopes::Builder do
  include Cuprum::Collections::RSpec::Deferred::Scopes::BuilderExamples

  subject(:builder) { described_class.instance }

  define_method :build_scope do
    Cuprum::Collections::Scopes::CriteriaScope.build({ 'ok' => true })
  end

  include_deferred 'should build collection Scopes',
    namespace: Cuprum::Collections::Basic::Scopes
end
