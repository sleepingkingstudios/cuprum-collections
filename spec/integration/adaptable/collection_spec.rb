# frozen_string_literal: true

require 'stannum'

require 'cuprum/collections'
require 'cuprum/collections/rspec/deferred/collection_examples'
require 'cuprum/collections/rspec/fixtures'

require 'support/adaptable/collection'
require 'support/book'
require 'support/grimoire'
require 'support/scoped_book'

RSpec.describe Spec::Support::Adaptable::Collection do
  include Cuprum::Collections::RSpec::Deferred::CollectionExamples

  subject(:collection) do
    described_class.new(
      adapter:,
      data:,
      **constructor_options
    )
  end

  shared_context 'when the collection has many items' do
    let(:data)  { Cuprum::Collections::RSpec::Fixtures::BOOKS_FIXTURES.dup }
    let(:items) { data }
  end

  let(:adapter) do
    Cuprum::Collections::Adapters::EntityAdapter
      .new(entity_class: Spec::BookEntity)
  end
  let(:name)                { 'books' }
  let(:data)                { [] }
  let(:constructor_options) { { name: } }
  let(:other_options)       { { adapter:, name: } }
  let(:expected_options)    { { default_entity_class: adapter.entity_class } }
  let(:query_class)         { Spec::Support::Adaptable::Query }
  let(:query_options)       { { adapter:, data: } }

  example_class 'Spec::BookEntity' do |klass|
    klass.include Stannum::Entity

    klass.define_primary_key :id,           Integer
    klass.define_attribute   :title,        String
    klass.define_attribute   :author,       String
    klass.define_attribute   :series,       String, optional: true
    klass.define_attribute   :category,     String, optional: true
    klass.define_attribute   :published_at, String, optional: true
  end

  describe '.new' do
    def call_method(**parameters)
      described_class.new(adapter:, data:, **parameters)
    end

    it 'should define the constructor' do
      expect(described_class)
        .to respond_to(:new)
        .with(0).arguments
        .and_keywords(:adapter, :data, :entity_class, :name, :qualified_name)
        .and_any_keywords
    end

    include_deferred 'should validate the Relation parameters'
  end

  include_deferred 'should be a Collection',
    commands_namespace:   'Cuprum::Collections::Basic::Commands',
    default_entity_class: -> { Spec::BookEntity },
    default_scope:        Cuprum::Collections::Basic::Scopes::AllScope
end
