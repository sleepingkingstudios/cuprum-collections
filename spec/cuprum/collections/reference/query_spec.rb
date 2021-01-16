# frozen_string_literal: true

require 'sleeping_king_studios/tools/string_tools'

require 'cuprum/collections/reference/query'
require 'cuprum/collections/rspec/query_contract'

RSpec.describe Cuprum::Collections::Reference::Query do
  subject(:query) { described_class.new(stringify_data(data)) }

  let(:data)          { [] }
  let(:expected_data) { stringify_data(matching_data) }

  def stringify_data(data)
    tools = SleepingKingStudios::Tools::HashTools.instance

    data.map { |hsh| tools.convert_keys_to_strings(hsh) }
  end

  describe '.new' do
    it { expect(described_class).to respond_to(:new).with(1).argument }
  end

  include_contract Cuprum::Collections::RSpec::QUERY_CONTRACT
end
