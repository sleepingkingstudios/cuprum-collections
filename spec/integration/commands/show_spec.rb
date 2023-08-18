# frozen_string_literal: true

require 'cuprum/collections/basic/collection'
require 'cuprum/collections/rspec/fixtures'

require 'support/commands/show'

RSpec.describe Spec::Support::Commands::Show do
  subject(:command) { described_class.new(collection) }

  let(:collection_name) { 'books' }
  let(:data)            { Cuprum::Collections::RSpec::BOOKS_FIXTURES.dup }
  let(:collection_options) do
    {
      collection_name: collection_name,
      data:            data
    }
  end
  let(:collection) do
    Cuprum::Collections::Basic::Collection.new(**collection_options)
  end

  describe '#call' do
    let(:primary_key) { 0 }
    let(:result)      { command.call(primary_key: primary_key) }

    describe 'with an invalid primary key' do
      let(:primary_key) { 100 }
      let(:expected_error) do
        Cuprum::Collections::Errors::NotFound.new(
          attribute_name:  'id',
          attribute_value: primary_key,
          collection_name: collection_name,
          primary_key:     true
        )
      end

      it { expect(result).to be_a_failing_result.with_error(expected_error) }
    end

    describe 'with a valid primary key' do
      let(:entity) do
        data.find { |item| item['id'] == primary_key }
      end

      it { expect(result).to be_a_passing_result.with_value(entity) }
    end
  end
end
