# frozen_string_literal: true

require 'cuprum/collections/adaptable/collection'
require 'cuprum/collections/rspec/deferred/collection_examples'

require 'support/book'
require 'support/grimoire'
require 'support/scoped_book'

RSpec.describe Cuprum::Collections::Adaptable::Collection do
  include Cuprum::Collections::RSpec::Deferred::CollectionExamples

  subject(:collection) do
    described_class.new(**constructor_options)
  end

  let(:described_class) { Spec::AdaptableCollection }
  let(:adapter) do
    Cuprum::Collections::Adapters::HashAdapter.new
  end
  let(:name)                { 'books' }
  let(:constructor_options) { { adapter:, name: } }
  let(:other_options)       { { adapter:, name: } }
  let(:expected_options)    { { default_entity_class: adapter.entity_class } }

  example_class 'Spec::AdaptableCollection', Cuprum::Collections::Collection \
  do |klass|
    klass.include Cuprum::Collections::Adaptable::Collection # rubocop:disable RSpec/DescribedClass
  end

  include_deferred 'should be a Collection',
    abstract:             true,
    default_entity_class: Hash

  describe '#adapter' do
    include_examples 'should define reader', :adapter, -> { adapter }
  end
end
