# frozen_string_literal: true

require 'bronze/association'
require 'bronze/rspec/deferred/association_examples'
require 'bronze/rspec/deferred/relation_examples'

require 'support/book'
require 'support/grimoire'
require 'support/scoped_book'

RSpec.describe Bronze::Association do
  include Bronze::RSpec::Deferred::AssociationExamples
  include Bronze::RSpec::Deferred::RelationExamples

  subject(:association) { described_class.new(**constructor_options) }

  let(:name)                { 'books' }
  let(:constructor_options) { { name: } }

  include_deferred 'should be a has Association'

  include_deferred 'should define Relation cardinality'
end
