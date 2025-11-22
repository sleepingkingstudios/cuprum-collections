# frozen_string_literal: true

require 'cuprum/collections/scopes/base'
require 'cuprum/collections/scopes/container'
require 'cuprum/collections/rspec/deferred/scope_examples'

RSpec.describe Cuprum::Collections::Scopes::Container do
  include Cuprum::Collections::RSpec::Deferred::ScopeExamples

  subject(:scope) { described_class.new(scopes:) }

  let(:described_class) { Spec::ExampleScope }
  let(:scopes)          { [] }

  example_class 'Spec::ExampleScope', Cuprum::Collections::Scopes::Base \
  do |klass|
    klass.include Cuprum::Collections::Scopes::Container # rubocop:disable RSpec/DescribedClass
  end

  def build_scope(...)
    Cuprum::Collections::Scope.new(...)
  end

  include_deferred 'should implement the Scope methods'

  include_deferred 'should define child scopes'
end
