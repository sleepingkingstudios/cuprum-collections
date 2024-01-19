# frozen_string_literal: true

require 'cuprum/collections/basic/collection'
require 'cuprum/collections/rspec/fixtures'

require 'support/commands/index'

RSpec.describe Spec::Support::Commands::Index do
  subject(:command) { described_class.new(collection) }

  let(:data) do
    Cuprum::Collections::RSpec::Fixtures::BOOKS_FIXTURES.dup
  end
  let(:collection_name) { 'books' }
  let(:collection_options) do
    {
      name: collection_name,
      data: data
    }
  end
  let(:collection) do
    Cuprum::Collections::Basic::Collection.new(**collection_options)
  end

  describe '#call' do
    let(:parameters) { {} }
    let(:expected)   { data }

    def an_enumerator
      an_instance_of(Enumerator)
        .and(satisfy { |value| value.to_a == expected.to_a })
    end

    it 'should return an enumerator' do
      expect(command.call(**parameters))
        .to be_a_passing_result
        .with_value(an_enumerator)
    end

    describe 'with envelope: true' do
      it 'should wrap the data in a hash' do
        expect(command.call(envelope: true, **parameters))
          .to be_a_passing_result
          .with_value({ 'books' => expected.to_a })
      end
    end

    describe 'with query parameters' do
      let(:filter) { { author: 'Ursula K. LeGuin' } }
      let(:limit)  { 3 }
      let(:offset) { 1 }
      let(:order)  { :title }
      let(:parameters) do
        {
          limit:  limit,
          offset: offset,
          order:  order,
          where:  filter
        }
      end
      let(:expected) do
        Cuprum::Collections::Basic::Query
          .new(data)
          .where(filter)
          .order(order)
          .limit(limit)
          .offset(offset)
      end

      it 'should return an enumerator' do
        expect(command.call(**parameters))
          .to be_a_passing_result
          .with_value(an_enumerator)
      end

      describe 'with envelope: true' do
        it 'should wrap the data in a hash' do
          expect(command.call(envelope: true, **parameters))
            .to be_a_passing_result
            .with_value({ 'books' => expected.to_a })
        end
      end
    end
  end
end
