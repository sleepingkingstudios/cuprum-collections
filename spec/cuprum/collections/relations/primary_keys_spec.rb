# frozen_string_literal: true

require 'cuprum/collections/relations/primary_keys'
require 'cuprum/collections/rspec/deferred/relation_examples'

RSpec.describe Cuprum::Collections::Relations::PrimaryKeys do
  include Cuprum::Collections::RSpec::Deferred::RelationExamples

  subject(:relation) { described_class.new(**constructor_options) }

  let(:described_class)     { Spec::ExampleRelation }
  let(:constructor_options) { {} }

  example_class 'Spec::ExampleRelation' do |klass|
    klass.include Cuprum::Collections::Relations::PrimaryKeys # rubocop:disable RSpec/DescribedClass

    klass.define_method(:initialize) { |**options| @options = options }

    klass.attr_reader :options
  end

  include_deferred 'should define Relation primary key'
end
