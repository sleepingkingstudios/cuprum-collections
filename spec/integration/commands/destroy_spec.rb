# frozen_string_literal: true

require 'cuprum/collections/basic/collection'
require 'cuprum/collections/rspec/fixtures'

require 'support/commands/destroy'

RSpec.describe Spec::Support::Commands::Destroy do
  subject(:command) { described_class.new(collection) }

  let(:data) do
    Cuprum::Collections::RSpec::Fixtures::BOOKS_FIXTURES.dup
  end
  let(:collection_name) { 'books' }
  let(:collection_options) do
    {
      name: collection_name,
      data:
    }
  end
  let(:collection) do
    Cuprum::Collections::Basic::Collection.new(**collection_options)
  end
  let(:query) do
    Cuprum::Collections::Basic::Query.new(collection.data)
  end

  describe '#call' do
    let(:primary_key) { 0 }
    let(:result)      { command.call(primary_key:) }

    describe 'with an invalid primary key' do
      let(:primary_key) { 100 }
      let(:expected_error) do
        Cuprum::Collections::Errors::NotFound.new(
          attribute_name:  'id',
          attribute_value: primary_key,
          collection_name:,
          primary_key:     true
        )
      end

      it { expect(result).to be_a_failing_result.with_error(expected_error) }

      it 'should not remove an item from the collection' do
        expect { command.call(primary_key:) }
          .not_to(change { query.reset.count })
      end
    end

    describe 'with a valid primary key' do
      let!(:entity) do
        data.find { |item| item['id'] == primary_key }
      end

      it { expect(result).to be_a_passing_result.with_value(entity) }

      it 'should remove an item from the collection' do
        expect { command.call(primary_key:) }.to(
          change { query.reset.count }.by(-1)
        )
      end

      it 'should remove the item from the collection' do
        command.call(primary_key:)

        value  = primary_key
        scoped = query.where { { id: value } }

        expect(scoped.exists?).to be false
      end
    end
  end
end
