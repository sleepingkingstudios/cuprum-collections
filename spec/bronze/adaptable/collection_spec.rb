# frozen_string_literal: true

require 'bronze/adaptable/collection'
require 'bronze/rspec/deferred/collection_examples'

require 'support/book'
require 'support/grimoire'
require 'support/scoped_book'

RSpec.describe Bronze::Adaptable::Collection do
  include Bronze::RSpec::Deferred::CollectionExamples

  subject(:collection) do
    described_class.new(**constructor_options)
  end

  let(:described_class)     { Spec::AdaptableCollection }
  let(:adapter)             { Bronze::Adapters::HashAdapter.new }
  let(:name)                { 'books' }
  let(:constructor_options) { { adapter:, name: } }
  let(:other_options)       { { adapter:, name: } }
  let(:expected_options)    { { default_entity_class: adapter.entity_class } }

  example_class 'Spec::AdaptableCollection', Bronze::Collection do |klass|
    klass.include Bronze::Adaptable::Collection # rubocop:disable RSpec/DescribedClass
  end

  include_deferred 'should be a Collection',
    abstract:             true,
    default_entity_class: Hash

  describe '#adapter' do
    include_examples 'should define reader', :adapter, -> { adapter }
  end
end
