# frozen_string_literal: true

require 'cuprum/collections/command'
require 'cuprum/collections/commands/query_command'
require 'cuprum/collections/query'

RSpec.describe Cuprum::Collections::Commands::QueryCommand do
  subject(:command) { described_class.new(query: query, **options) }

  let(:described_class) { Spec::ExampleCommand }
  let(:query)           { Struct.new(:call).new([]) }
  let(:options)         { {} }

  example_class 'Spec::ExampleCommand', Cuprum::Collections::Command do |klass|
    klass.include Cuprum::Collections::Commands::QueryCommand # rubocop:disable RSpec/DescribedClass
  end

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:query)
        .and_any_keywords
    end
  end

  describe '#query' do
    include_examples 'should define reader', :query, -> { query }
  end
end
