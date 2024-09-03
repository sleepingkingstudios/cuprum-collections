# frozen_string_literal: true

require 'cuprum/collections/basic/commands/update_one'
require 'cuprum/collections/rspec/deferred/commands/update_one_examples'

require 'support/examples/basic/command_examples'

RSpec.describe Cuprum::Collections::Basic::Commands::UpdateOne do
  include Cuprum::Collections::RSpec::Deferred::Commands::UpdateOneExamples
  include Spec::Support::Examples::Basic::CommandExamples

  subject(:command) { described_class.new(collection:) }

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
  let(:expected_data) do
    tools.hash_tools.convert_keys_to_strings(matching_data)
  end

  def tools
    SleepingKingStudios::Tools::Toolbelt.instance
  end

  include_deferred 'with parameters for a basic command'

  include_deferred 'should implement the Basic::Command methods'

  include_deferred 'should implement the UpdateOne command'

  wrap_deferred 'with a collection with a custom primary key' do
    let(:attributes) do
      super()
        .tap { |hsh| hsh.delete(:id) }
        .merge(uuid: '00000000-0000-0000-0000-000000000000')
    end

    include_deferred 'should implement the UpdateOne command'
  end
end
