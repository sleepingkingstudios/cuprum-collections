# frozen_string_literal: true

require 'cuprum/collections/basic/command'
require 'cuprum/collections/rspec/contracts/basic/command_contracts'
require 'cuprum/collections/rspec/fixtures'

RSpec.describe Cuprum::Collections::Basic::Command do
  include Cuprum::Collections::RSpec::Contracts::Basic::CommandContracts

  subject(:command) do
    described_class.new(
      collection_name:,
      data:,
      **constructor_options
    )
  end

  let(:data) do
    Cuprum::Collections::RSpec::Fixtures::BOOKS_FIXTURES.dup
  end
  let(:collection_name)     { 'books' }
  let(:constructor_options) { {} }

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

  describe '#call' do
    it 'should define the method' do
      expect(command)
        .to respond_to(:call)
        .with_unlimited_arguments
        .and_any_keywords
    end

    it 'should return a failing result with not implemented error' do
      expect(command.call)
        .to be_a_failing_result
        .with_error(an_instance_of Cuprum::Errors::CommandNotImplemented)
    end
  end
end
