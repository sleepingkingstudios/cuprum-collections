# frozen_string_literal: true

require 'bronze/scopes/base'
require 'bronze/scopes/container'
require 'cuprum/collections/rspec/deferred/scope_examples'

RSpec.describe Bronze::Scopes::Container do
  include Cuprum::Collections::RSpec::Deferred::ScopeExamples

  subject(:scope) { described_class.new(scopes:) }

  let(:described_class) { Spec::ExampleScope }
  let(:scopes)          { [] }

  example_class 'Spec::ExampleScope', Bronze::Scopes::Base do |klass|
    klass.include Bronze::Scopes::Container # rubocop:disable RSpec/DescribedClass
  end

  def build_scope(...)
    Bronze::Scope.new(...)
  end

  include_deferred 'should implement the Scope methods'

  include_deferred 'should define child scopes'
end
