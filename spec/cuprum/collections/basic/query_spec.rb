# frozen_string_literal: true

require 'sleeping_king_studios/tools/string_tools'

require 'cuprum/collections/basic/query'
require 'cuprum/collections/rspec/contracts/query_contracts'

RSpec.describe Cuprum::Collections::Basic::Query do
  include Cuprum::Collections::RSpec::Contracts::QueryContracts

  subject(:query) { described_class.new(stringify_data(data)) }

  let(:data)          { [] }
  let(:expected_data) { stringify_data(matching_data) }

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

  include_contract 'should be a query'
end
