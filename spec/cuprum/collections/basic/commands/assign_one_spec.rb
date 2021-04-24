# frozen_string_literal: true

require 'stannum/constraints/types/hash_with_string_keys'

require 'cuprum/collections/basic/commands/assign_one'
require 'cuprum/collections/basic/rspec/command_contract'
require 'cuprum/collections/rspec/assign_one_command_contract'

RSpec.describe Cuprum::Collections::Basic::Commands::AssignOne do
  subject(:command) do
    described_class.new(
      collection_name: collection_name,
      data:            data,
      **constructor_options
    )
  end

  let(:collection_name)     { 'books' }
  let(:data)                { [] }
  let(:constructor_options) { {} }
  let(:initial_attributes)  { {} }
  let(:entity)              { initial_attributes }
  let(:entity_type) do
    Stannum::Constraints::Types::HashWithStringKeys.new
  end
  let(:expected_value) do
    SleepingKingStudios::Tools::HashTools
      .instance
      .convert_keys_to_strings(expected_attributes)
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

  include_contract Cuprum::Collections::RSpec::ASSIGN_ONE_COMMAND_CONTRACT,
    allow_extra_attributes: true
end
