# frozen_string_literal: true

require 'cuprum/collections/association'
require 'cuprum/collections/rspec/deferred/association_examples'
require 'cuprum/collections/rspec/deferred/relation_examples'

require 'support/book'
require 'support/grimoire'
require 'support/scoped_book'

RSpec.describe Cuprum::Collections::Association do
  include Cuprum::Collections::RSpec::Deferred::AssociationExamples
  include Cuprum::Collections::RSpec::Deferred::RelationExamples

  subject(:association) { described_class.new(**constructor_options) }

  let(:name)                { 'books' }
  let(:constructor_options) { { name: } }

  include_deferred 'should be a has Association'

  include_deferred 'should define Relation cardinality'
end
