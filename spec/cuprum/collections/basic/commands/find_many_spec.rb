# frozen_string_literal: true

require 'cuprum/collections/basic/commands/find_many'
require 'cuprum/collections/rspec/contracts/basic/command_contracts'
require 'cuprum/collections/rspec/contracts/command_contracts'

RSpec.describe Cuprum::Collections::Basic::Commands::FindMany do
  include Cuprum::Collections::RSpec::Contracts::Basic::CommandContracts
  include Cuprum::Collections::RSpec::Contracts::CommandContracts

  with_contract 'with basic command contexts'

  include_context 'with parameters for a basic contract'

  subject(:command) do
    described_class.new(
      collection_name:,
      data:            mapped_data,
      query:,
      **constructor_options
    )
  end

  let(:data)        { [] }
  let(:mapped_data) { data }
  let(:query)       { Cuprum::Collections::Basic::Query.new(mapped_data) }

  describe '.new' do
    let(:keywords) do
      %i[
        collection_name
        data
        primary_key_name
        primary_key_type
        query
      ]
    end

    it 'should define the constructor' do
      expect(described_class)
        .to respond_to(:new)
        .with(0).arguments
        .and_keywords(*keywords)
        .and_any_keywords
    end
  end

  include_contract 'should be a basic command'

  include_contract 'should be a find many command'

  wrap_context 'with a custom primary key' do
    include_contract 'should be a find many command'
  end
end
