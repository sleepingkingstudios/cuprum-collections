# frozen_string_literal: true

require 'cuprum/collections/basic/commands/insert_one'
require 'cuprum/collections/basic/query'
require 'cuprum/collections/basic/rspec/command_contract'
require 'cuprum/collections/rspec/insert_one_command_contract'

require 'support/examples/basic_command_examples'

RSpec.describe Cuprum::Collections::Basic::Commands::InsertOne do
  include Spec::Support::Examples::BasicCommandExamples

  include_context 'with parameters for a basic contract'

  subject(:command) do
    described_class.new(
      collection_name: collection_name,
      data:            mapped_data,
      **constructor_options
    )
  end

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

  wrap_context 'with a custom primary key' do # rubocop:disable RSpec/EmptyExampleGroup
    let(:attributes) do
      super()
        .tap { |hsh| hsh.delete(:id) }
        .merge(uuid: '00000000-0000-0000-0000-000000000000')
    end

    include_contract Cuprum::Collections::RSpec::INSERT_ONE_COMMAND_CONTRACT
  end
end
