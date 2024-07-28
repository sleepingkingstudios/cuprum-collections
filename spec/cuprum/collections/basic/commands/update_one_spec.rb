# frozen_string_literal: true

require 'cuprum/collections/basic/commands/update_one'
require 'cuprum/collections/basic/query'
require 'cuprum/collections/rspec/contracts/basic/command_contracts'
require 'cuprum/collections/rspec/contracts/command_contracts'

RSpec.describe Cuprum::Collections::Basic::Commands::UpdateOne do
  include Cuprum::Collections::RSpec::Contracts::Basic::CommandContracts
  include Cuprum::Collections::RSpec::Contracts::CommandContracts

  with_contract 'with basic command contexts'

  include_context 'with parameters for a basic contract'

  subject(:command) do
    described_class.new(
      collection_name:,
      data:            mapped_data,
      **constructor_options
    )
  end

  let(:attributes) do
    {
      id:     0,
      title:  'Gideon the Ninth',
      author: 'Tamsyn Muir'
    }
  end
  let(:entity) do
    tools.hash_tools.convert_keys_to_strings(attributes)
  end
  let(:query) do
    Cuprum::Collections::Basic::Query.new(mapped_data)
  end
  let(:expected_data) do
    tools.hash_tools.convert_keys_to_strings(matching_data)
  end

  def tools
    SleepingKingStudios::Tools::Toolbelt.instance
  end

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to respond_to(:new)
        .with(0).arguments
        .and_keywords(:collection_name, :data)
        .and_any_keywords
    end
  end

  include_contract 'should be a basic command'

  include_contract 'should be an update one command'

  wrap_context 'with a custom primary key' do
    let(:attributes) do
      super()
        .tap { |hsh| hsh.delete(:id) }
        .merge(uuid: '00000000-0000-0000-0000-000000000000')
    end

    include_contract 'should be an update one command'
  end
end
