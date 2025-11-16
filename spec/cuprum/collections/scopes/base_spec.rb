# frozen_string_literal: true

require 'cuprum/collections/scopes/base'
require 'cuprum/collections/rspec/deferred/scope_examples'

RSpec.describe Cuprum::Collections::Scopes::Base do
  include Cuprum::Collections::RSpec::Deferred::ScopeExamples

  let(:scope) { described_class.new }

  describe '::UninvertibleScopeException' do
    include_examples 'should define constant',
      :UninvertibleScopeException,
      -> { be_a(Class).and(be < StandardError) }
  end

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_any_keywords
    end
  end

  include_deferred 'should be a Scope'

  include_deferred 'should compose scopes'

  describe '#==' do
    it { expect(scope == nil).to be false } # rubocop:disable Style/NilComparison

    it { expect(scope == Object.new.freeze).to be false }

    describe 'with a scope with the same class' do
      let(:other) { described_class.new }

      it { expect(scope == other).to be true }
    end

    describe 'with a scope with the same type' do
      let(:other) { Spec::CustomScope.new }

      # rubocop:disable RSpec/DescribedClass
      example_class 'Spec::CustomScope', Cuprum::Collections::Scopes::Base \
      do |klass|
        klass.define_method(:type) { :abstract }
      end
      # rubocop:enable RSpec/DescribedClass

      it { expect(scope == other).to be true }
    end
  end

  describe '#builder' do
    let(:expected) { Cuprum::Collections::Scopes::Builder.instance }

    include_examples 'should define private reader', :builder, -> { expected }
  end

  describe '#empty?' do
    include_examples 'should define predicate', :empty?, false
  end

  describe '#type' do
    include_examples 'should define reader', :type, :abstract
  end
end
