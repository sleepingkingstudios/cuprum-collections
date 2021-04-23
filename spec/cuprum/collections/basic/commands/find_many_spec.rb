# frozen_string_literal: true

require 'cuprum/collections/basic/commands/find_many'
require 'cuprum/collections/basic/rspec/command_contract'
require 'cuprum/collections/rspec/find_many_command_contract'

RSpec.describe Cuprum::Collections::Basic::Commands::FindMany do
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
  let(:expected_options)    { {} }

  describe '.new' do
    let(:keywords) do
      %i[
        collection_name
        data
        primary_key_name
        primary_key_type
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

  include_contract Cuprum::Collections::Basic::RSpec::COMMAND_CONTRACT

  include_contract Cuprum::Collections::RSpec::FIND_MANY_COMMAND_CONTRACT

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
    let(:invalid_primary_key_values) do
      %w[
        00000000-0000-0000-0000-000000000100
        00000000-0000-0000-0000-000000000101
        00000000-0000-0000-0000-000000000102
      ]
    end
    let(:valid_primary_key_values) do
      %w[
        00000000-0000-0000-0000-000000000000
        00000000-0000-0000-0000-000000000001
        00000000-0000-0000-0000-000000000002
      ]
    end

    include_contract Cuprum::Collections::RSpec::FIND_MANY_COMMAND_CONTRACT
  end
end
