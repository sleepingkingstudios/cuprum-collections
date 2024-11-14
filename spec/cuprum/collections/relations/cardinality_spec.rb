# frozen_string_literal: true

require 'cuprum/collections/relations/cardinality'
require 'cuprum/collections/rspec/deferred/relation_examples'

RSpec.describe Cuprum::Collections::Relations::Cardinality do
  include Cuprum::Collections::RSpec::Deferred::RelationExamples

  subject(:relation) { described_class.new(**constructor_options) }

  let(:described_class)     { Spec::ExampleRelation }
  let(:constructor_options) { {} }

  example_class 'Spec::ExampleRelation' do |klass|
    klass.include Cuprum::Collections::Relations::Cardinality # rubocop:disable RSpec/DescribedClass

    klass.define_method(:initialize) do |**options|
      @plural = resolve_plurality(**options)
    end
  end

  include_deferred 'should define Relation cardinality'
end
