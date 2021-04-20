# frozen_string_literal: true

require 'cuprum/collections/reference/command'
require 'cuprum/collections/reference/rspec/command_contract'
require 'cuprum/collections/rspec/fixtures'

RSpec.describe Cuprum::Collections::Reference::Command do
  subject(:command) do
    described_class.new(
      collection_name: collection_name,
      data:            data,
      **constructor_options
    )
  end

  let(:collection_name)     { 'books' }
  let(:data)                { Cuprum::Collections::RSpec::BOOKS_FIXTURES }
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

  include_contract Cuprum::Collections::Reference::RSpec::COMMAND_CONTRACT

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
