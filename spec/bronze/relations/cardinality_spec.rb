# frozen_string_literal: true

require 'bronze/relations/cardinality'
require 'bronze/relations/options'
require 'cuprum/collections/rspec/deferred/relation_examples'

RSpec.describe Bronze::Relations::Cardinality do
  include Cuprum::Collections::RSpec::Deferred::RelationExamples

  subject(:relation) { described_class.new(**constructor_options) }

  let(:described_class)     { Spec::ExampleRelation }
  let(:constructor_options) { {} }

  example_class 'Spec::ExampleRelation' do |klass|
    klass.include Bronze::Relations::Options
    klass.include Bronze::Relations::Cardinality # rubocop:disable RSpec/DescribedClass
  end

  include_deferred 'should define Relation cardinality'
end
