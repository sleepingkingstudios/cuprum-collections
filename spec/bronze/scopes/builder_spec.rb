# frozen_string_literal: true

require 'bronze/scopes/builder'
require 'cuprum/collections/rspec/deferred/scopes/builder_examples'

RSpec.describe Bronze::Scopes::Builder do
  include Cuprum::Collections::RSpec::Deferred::Scopes::BuilderExamples

  subject(:builder) { described_class.instance }

  define_method :build_scope do
    Bronze::Scopes::CriteriaScope.build({ 'ok' => true })
  end

  include_deferred 'should build collection Scopes', namespace: Bronze::Scopes
end
