# frozen_string_literal: true

require 'bronze/relation'
require 'cuprum/collections/rspec/deferred/relation_examples'

require 'support/book'
require 'support/grimoire'
require 'support/scoped_book'

RSpec.describe Bronze::Relation do
  include Cuprum::Collections::RSpec::Deferred::RelationExamples

  subject(:relation) { described_class.new(**constructor_options) }

  let(:name)                { 'books' }
  let(:constructor_options) { { name: } }

  include_deferred 'should be a Relation'
end
