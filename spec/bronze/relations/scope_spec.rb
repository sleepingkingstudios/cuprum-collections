# frozen_string_literal: true

require 'bronze/relations/options'
require 'bronze/relations/scope'
require 'cuprum/collections/rspec/deferred/relation_examples'

RSpec.describe Bronze::Relations::Scope do
  include Cuprum::Collections::RSpec::Deferred::RelationExamples

  subject(:relation) { described_class.new(**constructor_options) }

  let(:described_class)     { Spec::ExampleRelation }
  let(:constructor_options) { {} }

  example_class 'Spec::ExampleRelation' do |klass|
    klass.include Bronze::Relations::Options
    klass.include Bronze::Relations::Scope # rubocop:disable RSpec/DescribedClass
  end

  include_deferred 'should define Relation scope'

  describe '#scope' do
    context 'when the relation defines a default scope' do
      let(:default_scope) do
        Cuprum::Collections::Scope.new do |query|
          { series: query.not_equal(nil) }
        end
      end
      let(:expected) { default_scope }

      before(:example) do
        value = default_scope

        described_class.define_method(:default_scope) { value }
      end

      it { expect(relation.scope).to match_scope(expected) }
    end
  end
end
