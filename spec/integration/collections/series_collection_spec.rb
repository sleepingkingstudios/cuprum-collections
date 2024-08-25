# frozen_string_literal: true

require 'cuprum/collections/scope'
require 'cuprum/collections/rspec/fixtures'

# @note: Integration spec for a collection
RSpec.describe Cuprum::Collections::Basic do
  subject(:collection) do
    described_class.new(
      data:  Cuprum::Collections::RSpec::Fixtures::BOOKS_FIXTURES,
      name:  'books',
      scope: series_scope
    )
  end

  let(:series_scope) do
    Cuprum::Collections::Scope.new do |scope|
      { series: scope.not_equal(nil) }
    end
  end

  describe '#find_many' do
    let(:command) { collection.find_many }

    describe 'with primary keys that do not match the scope' do
      let(:primary_keys) { [0, 1] }

      it 'should return a failing result' do
        expect(command.call(primary_keys:))
          .to be_a_failing_result
          .with_error(an_instance_of(Cuprum::Errors::MultipleErrors))
      end
    end

    describe 'with primary keys that match the scope' do
      let(:primary_keys) { [2, 3, 4] }
      let(:expected_value) do
        primary_keys.map do |id|
          Cuprum::Collections::RSpec::Fixtures::BOOKS_FIXTURES.find do |book|
            book['id'] == id
          end
        end
      end

      it 'should return a passing result' do
        expect(command.call(primary_keys:))
          .to be_a_passing_result
          .with_value(expected_value)
      end
    end
  end

  describe '#find_matching' do
    let(:command) { collection.find_matching }
    let(:matching_data) do
      Cuprum::Collections::RSpec::Fixtures::BOOKS_FIXTURES.reject do |book|
        book['series'].nil?
      end
    end

    it 'should return a passing result', :aggregate_failures do
      result = command.call

      expect(result).to be_a_passing_result
      expect(result.value).to be_a Enumerator
      expect(result.value.to_a).to match_array(matching_data)
    end

    describe 'with additional filters' do
      let(:matching_data) do
        super().select { |book| book['author'] == 'Ursula K. LeGuin' }
      end

      it 'should return a passing result', :aggregate_failures do
        result = command.call(where: { 'author' => 'Ursula K. LeGuin' })

        expect(result).to be_a_passing_result
        expect(result.value).to be_a Enumerator
        expect(result.value.to_a).to match_array(matching_data)
      end
    end
  end

  describe '#find_one' do
    let(:command) { collection.find_one }

    describe 'with a primary key that does not match the scope' do
      let(:primary_key) { 0 }

      it 'should return a failing result' do
        expect(command.call(primary_key:))
          .to be_a_failing_result
          .with_error(an_instance_of(Cuprum::Collections::Errors::NotFound))
      end
    end

    describe 'with a primary key that matches the scope' do
      let(:primary_key) { 2 }
      let(:expected_value) do
        Cuprum::Collections::RSpec::Fixtures::BOOKS_FIXTURES.find do |book|
          book['id'] == primary_key
        end
      end

      it 'should return a passing result' do
        expect(command.call(primary_key:))
          .to be_a_passing_result
          .with_value(expected_value)
      end
    end
  end

  describe '#query' do
    let(:matching_data) do
      Cuprum::Collections::RSpec::Fixtures::BOOKS_FIXTURES.reject do |book|
        book['series'].nil?
      end
    end
    let(:query) { collection.query }

    it { expect(query.scope).to be == series_scope }

    it { expect(query.to_a).to match_array(matching_data) }

    describe 'with additional filters' do
      let(:matching_data) do
        super().select { |book| book['author'] == 'Ursula K. LeGuin' }
      end
      let(:query) { super().where({ 'author' => 'Ursula K. LeGuin' }) }

      it { expect(query.to_a).to match_array(matching_data) }
    end
  end

  describe '#scope' do
    include_examples 'should define reader', :scope, -> { series_scope }
  end
end
