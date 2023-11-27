# frozen_string_literal: true

require 'cuprum/collections/basic/query_builder'
require 'cuprum/collections/rspec/contracts/query_contracts'

RSpec.describe Cuprum::Collections::Basic::QueryBuilder do
  include Cuprum::Collections::RSpec::Contracts::QueryContracts

  shared_context 'when the query has criteria' do
    let(:base_query) do
      super().where do
        {
          title:  ne(nil),
          author: ne(nil),
          series: ne(nil)
        }
      end
    end
  end

  subject(:builder) { described_class.new(base_query) }

  let(:base_query) { Cuprum::Collections::Basic::Query.new([]) }

  describe '.new' do
    it { expect(described_class).to respond_to(:new).with(1).argument }
  end

  include_contract 'should be a query builder'

  describe '#call' do
    def match_item(expected)
      satisfy do |actual|
        actual.all? { |filter| filter.call(expected) }
      end
    end

    describe 'with where: a block' do
      let(:block)   { -> { { author: 'Nnedi Okorafor', series: 'Binti' } } }
      let(:query)   { builder.call(where: block) }
      let(:filters) { query.send(:filters) }

      it { expect(filters).to be_a Array }

      it { expect(filters.size).to be 2 }

      describe 'with a matching item' do
        let(:actual) do
          {
            'title'  => 'Binti: The Night Masquerade',
            'author' => 'Nnedi Okorafor',
            'series' => 'Binti'
          }
        end

        it { expect(filters).to match_item(actual) }
      end

      describe 'with a partially matching item' do
        let(:actual) do
          {
            'title'  => 'Akata Witch',
            'author' => 'Nnedi Okorafor'
          }
        end

        it { expect(filters).not_to match_item(actual) }
      end

      describe 'with a non-matching item' do
        let(:actual) do
          {
            'title'  => 'Zahrah the Windseeker',
            'author' => 'Nnedi Okorafor-Mbachu'
          }
        end

        it { expect(filters).not_to match_item(actual) }
      end

      wrap_context 'when the query has criteria' do
        it { expect(filters).to be_a Array }

        it { expect(filters.size).to be 5 }

        describe 'with a matching item' do
          let(:actual) do
            {
              'title'  => 'Binti: The Night Masquerade',
              'author' => 'Nnedi Okorafor',
              'series' => 'Binti'
            }
          end

          it { expect(filters).to match_item(actual) }
        end

        describe 'with a partially matching item' do
          let(:actual) do
            {
              'title'  => nil,
              'author' => 'Nnedi Okorafor',
              'series' => 'Binti'
            }
          end

          it { expect(filters).not_to match_item(actual) }
        end

        describe 'with a non-matching item' do
          let(:actual) do
            {
              'title'  => 'Zahrah the Windseeker',
              'author' => 'Nnedi Okorafor-Mbachu'
            }
          end

          it { expect(filters).not_to match_item(actual) }
        end
      end
    end
  end
end
