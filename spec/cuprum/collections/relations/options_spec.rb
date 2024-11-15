# frozen_string_literal: true

require 'cuprum/collections/relations/options'
require 'cuprum/collections/rspec/deferred/relation_examples'

RSpec.describe Cuprum::Collections::Relations::Options do
  include Cuprum::Collections::RSpec::Deferred::RelationExamples

  subject(:relation) { described_class.new(**constructor_options) }

  let(:described_class)     { Spec::ExampleRelation }
  let(:constructor_options) { {} }

  example_class 'Spec::ExampleRelation' do |klass|
    klass.include Cuprum::Collections::Relations::Options # rubocop:disable RSpec/DescribedClass
  end

  include_deferred 'should define Relation options'
end
