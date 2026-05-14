# frozen_string_literal: true

require 'bronze/commands/query_command'
require 'bronze/query'

RSpec.describe Bronze::Commands::QueryCommand do
  subject(:command) { described_class.new(query:, **options) }

  let(:described_class) { Spec::ExampleCommand }
  let(:query)           { Struct.new(:call).new([]) }
  let(:options)         { {} }
  let(:tools) do
    SleepingKingStudios::Tools::Toolbelt.instance
  end

  before(:example) do
    allow(tools.core_tools).to receive(:deprecate)
  end

  example_class 'Spec::ExampleCommand', Cuprum::Command do |klass|
    klass.include Bronze::Commands::QueryCommand # rubocop:disable RSpec/DescribedClass
  end

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:query)
        .and_any_keywords
    end

    it 'should print a deprecation warning' do
      described_class.new(query:, **options)

      expect(tools.core_tools)
        .to have_received(:deprecate)
        .with('Bronze::Commands::QueryCommand')
    end
  end

  describe '#query' do
    include_examples 'should define reader', :query, -> { query }
  end
end
