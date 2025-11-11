# frozen_string_literal: true

require 'sleeping_king_studios/tools/string_tools'

require 'cuprum/collections/basic/query'
require 'cuprum/collections/rspec/deferred/query_examples'

RSpec.describe Cuprum::Collections::Basic::Query do
  include Cuprum::Collections::RSpec::Deferred::QueryExamples

  subject(:query) do
    described_class.new(
      stringify_data(data),
      scope: initial_scope
    )
  end

  let(:data)          { [] }
  let(:matching_data) { data }
  let(:expected_data) { stringify_data(matching_data) }
  let(:initial_scope) { nil }

  def add_item_to_collection(item)
    tools = SleepingKingStudios::Tools::HashTools.instance

    query.send(:data) << tools.convert_keys_to_strings(item)
  end

  def stringify_data(data)
    tools = SleepingKingStudios::Tools::HashTools.instance

    data.map { |hsh| tools.convert_keys_to_strings(hsh) }
  end

  describe '.new' do
    it { expect(described_class).to respond_to(:new).with(1).argument }
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
