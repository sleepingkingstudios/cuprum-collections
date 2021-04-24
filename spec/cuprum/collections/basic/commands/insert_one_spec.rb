# frozen_string_literal: true

require 'cuprum/collections/basic/commands/insert_one'
require 'cuprum/collections/basic/query'
require 'cuprum/collections/basic/rspec/command_contract'
require 'cuprum/collections/rspec/insert_one_command_contract'

RSpec.describe Cuprum::Collections::Basic::Commands::InsertOne do
  subject(:command) do
    described_class.new(
      collection_name: collection_name,
      data:            mapped_data,
      **constructor_options
    )
  end

  let(:collection_name)     { 'books' }
  let(:data)                { [] }
  let(:mapped_data)         { data }
  let(:constructor_options) { {} }
  let(:primary_key_name)    { :id }
  let(:primary_key_type)    { Integer }
  let(:attributes) do
    {
      id:     0,
      title:  'Gideon the Ninth',
      author: 'Tammsyn Muir'
    }
  end
  let(:entity) do
    tools.hash_tools.convert_keys_to_strings(attributes)
  end
  let(:entity_type) do
    Stannum::Constraints::Types::HashWithStringKeys.new
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

  include_contract Cuprum::Collections::Basic::RSpec::COMMAND_CONTRACT

  include_contract Cuprum::Collections::RSpec::INSERT_ONE_COMMAND_CONTRACT

  context 'with a custom primary key' do # rubocop:disable RSpec/EmptyExampleGroup
    let(:primary_key_name) { :uuid }
    let(:primary_key_type) { String }
    let(:constructor_options) do
      super().merge(
        primary_key_name: primary_key_name,
        primary_key_type: primary_key_type
      )
    end
    let(:mapped_data) do
      data.map do |item|
        item.dup.tap do |hsh|
          value = hsh.delete('id').to_s.rjust(12, '0')

          hsh['uuid'] = "00000000-0000-0000-0000-#{value}"
        end
      end
    end
    let(:attributes) do
      super()
        .tap { |hsh| hsh.delete(:id) }
        .merge(uuid: '00000000-0000-0000-0000-000000000000')
    end

    include_contract Cuprum::Collections::RSpec::INSERT_ONE_COMMAND_CONTRACT
  end
end
