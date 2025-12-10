# frozen_string_literal: true

require 'cuprum/collections/rspec/deferred/query_examples'
require 'cuprum/collections/rspec/fixtures'

require 'support/adaptable/query'

RSpec.describe Spec::Support::Adaptable::Query do
  include Cuprum::Collections::RSpec::Deferred::QueryExamples

  subject(:query) do
    described_class.new(stringify_data(data), adapter:, scope: initial_scope)
  end

  let(:adapter) do
    Cuprum::Collections::Adapters::EntityAdapter
      .new(entity_class: Spec::BookEntity)
  end
  let(:data)          { [] }
  let(:matching_data) { data }
  let(:expected_data) { convert_data_to_entities(matching_data) }
  let(:initial_scope) { nil }

  example_class 'Spec::BookEntity' do |klass|
    klass.include Stannum::Entity

    klass.define_primary_key :id,           Integer
    klass.define_attribute   :title,        String
    klass.define_attribute   :author,       String
    klass.define_attribute   :series,       String, optional: true
    klass.define_attribute   :category,     String, optional: true
    klass.define_attribute   :published_at, String, optional: true
  end

  define_method :add_item_to_collection do |item|
    tools = SleepingKingStudios::Tools::HashTools.instance

    query.send(:data) << tools.convert_keys_to_strings(item)
  end

  define_method :convert_data_to_entities do |data|
    stringify_data(data).map { |attributes| Spec::BookEntity.new(**attributes) }
  end

  define_method :stringify_data do |data|
    tools = SleepingKingStudios::Tools::HashTools.instance

    data.map { |hsh| tools.convert_keys_to_strings(hsh) }
  end

  include_deferred 'should be a Query'

  describe '#scope' do
    it 'should define the default scope' do
      expect(query.scope).to be_a Cuprum::Collections::Basic::Scopes::AllScope
    end

    wrap_context 'when initialized with a scope' do
      it 'should transform the scope' do
        expect(query.scope)
          .to be_a Cuprum::Collections::Basic::Scopes::CriteriaScope
      end
    end
  end
end
