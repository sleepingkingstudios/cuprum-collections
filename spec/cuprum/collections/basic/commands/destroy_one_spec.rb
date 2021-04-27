# frozen_string_literal: true

require 'cuprum/collections/basic/commands/destroy_one'
require 'cuprum/collections/basic/rspec/command_contract'
require 'cuprum/collections/rspec/destroy_one_command_contract'

require 'support/examples/basic_command_examples'

RSpec.describe Cuprum::Collections::Basic::Commands::DestroyOne do
  include Spec::Support::Examples::BasicCommandExamples

  include_context 'with parameters for a basic contract'

  subject(:command) do
    described_class.new(
      collection_name: collection_name,
      data:            mapped_data,
      **constructor_options
    )
  end

  describe '.new' do
    let(:keywords) do
      %i[collection_name data primary_key_name primary_key_type]
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

  include_contract Cuprum::Collections::RSpec::DESTROY_ONE_COMMAND_CONTRACT

  wrap_context 'with a custom primary key' do # rubocop:disable RSpec/EmptyExampleGroup
    include_contract Cuprum::Collections::RSpec::DESTROY_ONE_COMMAND_CONTRACT
  end
end
