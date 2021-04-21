# frozen_string_literal: true

require 'cuprum/collections/basic/commands/find_one'
require 'cuprum/collections/basic/rspec/command_contract'
require 'cuprum/collections/rspec/find_one_command_contract'

RSpec.describe Cuprum::Collections::Basic::Commands::FindOne do
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
  let(:expected_options)    { { envelope: false } }

  describe '.new' do
    let(:keywords) do
      %i[collection_name data envelope primary_key_name primary_key_type]
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

  include_contract Cuprum::Collections::RSpec::FIND_ONE_COMMAND_CONTRACT

  describe '#envelope?' do
    include_examples 'should define predicate', :envelope?, false

    context 'when initialized with envelope: true' do
      let(:constructor_options) { super().merge(envelope: true) }

      it { expect(command.envelope?).to be true }
    end
  end

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
    let(:invalid_primary_key_value) { '00000000-0000-0000-0000-000000000100' }
    let(:valid_primary_key_value)   { '00000000-0000-0000-0000-000000000000' }

    include_contract Cuprum::Collections::RSpec::FIND_ONE_COMMAND_CONTRACT
  end
end
