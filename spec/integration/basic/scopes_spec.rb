# frozen_string_literal: true

require 'cuprum/collections/basic/scopes/conjunction_scope'
require 'cuprum/collections/basic/scopes/criteria_scope'
require 'cuprum/collections/basic/scopes/disjunction_scope'
require 'cuprum/collections/basic/scopes/negation_scope'
require 'cuprum/collections/rspec/fixtures'
require 'cuprum/collections/queries'
require 'cuprum/collections/scope'

RSpec.describe Cuprum::Collections::Basic::Scopes do
  let(:data) { Cuprum::Collections::RSpec::Fixtures::BOOKS_FIXTURES }
  let(:complex_scope) do
    Cuprum::Collections::Scope
      .new { { 'published_at' => greater_than('1973-01-01') } }
      .not({ 'series' => nil })
  end

  describe 'with an empty scope' do
    let(:scope)     { described_class::CriteriaScope.new(criteria: []) }
    let(:inspected) { 'Basic::CriteriaScope (0)' }
    let(:matching)  { data }

    it { expect(scope.debug).to be == inspected }

    it { expect(scope.call(data: data)).to be == matching }

    describe '#and a block' do
      let(:block) { -> { { 'series' => 'Earthsea' } } }
      let(:scope) { super().and(&block) }
      let(:inspected) do
        <<~TEXT.strip
          Basic::CriteriaScope (1):
          - "series" equal "Earthsea"
        TEXT
      end
      let(:matching) do
        super().select { |book| book['series'] == 'Earthsea' }
      end

      it { expect(scope.debug).to be == inspected }

      it { expect(scope.call(data: data)).to be == matching }
    end

    describe '#and a hash' do
      let(:value) { { 'series' => 'Earthsea' } }
      let(:scope) { super().and(value) }
      let(:inspected) do
        <<~TEXT.strip
          Basic::CriteriaScope (1):
          - "series" equal "Earthsea"
        TEXT
      end
      let(:matching) do
        super().select { |book| book['series'] == 'Earthsea' }
      end

      it { expect(scope.debug).to be == inspected }

      it { expect(scope.call(data: data)).to be == matching }
    end

    describe '#and a basic scope' do
      let(:value) { Cuprum::Collections::Scope.new({ 'series' => 'Earthsea' }) }
      let(:scope) { super().and(value) }
      let(:inspected) do
        <<~TEXT.strip
          Basic::CriteriaScope (1):
          - "series" equal "Earthsea"
        TEXT
      end
      let(:matching) do
        super().select { |book| book['series'] == 'Earthsea' }
      end

      it { expect(scope.debug).to be == inspected }

      it { expect(scope.call(data: data)).to be == matching }
    end

    describe '#and a complex scope' do
      let(:scope) { super().and(complex_scope) }
      let(:inspected) do
        <<~TEXT.strip
          Basic::ConjunctionScope (2):
          - Basic::CriteriaScope (1):
            - "published_at" greater_than "1973-01-01"
          - Basic::NegationScope (1):
            - Basic::CriteriaScope (1):
              - "series" equal nil
        TEXT
      end
      let(:matching) do
        super()
          .select { |book| book['published_at'] > '1973-01-01' }
          .reject { |book| book['series'].nil? }
      end

      it { expect(scope.debug).to be == inspected }

      it { expect(scope.call(data: data)).to be == matching }
    end

    describe '#or a block' do
      let(:block) { -> { { 'series' => 'Earthsea' } } }
      let(:scope) { super().or(&block) }
      let(:inspected) do
        <<~TEXT.strip
          Basic::CriteriaScope (1):
          - "series" equal "Earthsea"
        TEXT
      end
      let(:matching) do
        super().select { |book| book['series'] == 'Earthsea' }
      end

      it { expect(scope.debug).to be == inspected }

      it { expect(scope.call(data: data)).to be == matching }
    end

    describe '#or a hash' do
      let(:value) { { 'series' => 'Earthsea' } }
      let(:scope) { super().or(value) }
      let(:inspected) do
        <<~TEXT.strip
          Basic::CriteriaScope (1):
          - "series" equal "Earthsea"
        TEXT
      end
      let(:matching) do
        super().select { |book| book['series'] == 'Earthsea' }
      end

      it { expect(scope.debug).to be == inspected }

      it { expect(scope.call(data: data)).to be == matching }
    end

    describe '#or a basic scope' do
      let(:value) { Cuprum::Collections::Scope.new({ 'series' => 'Earthsea' }) }
      let(:scope) { super().or(value) }
      let(:inspected) do
        <<~TEXT.strip
          Basic::CriteriaScope (1):
          - "series" equal "Earthsea"
        TEXT
      end
      let(:matching) do
        super().select { |book| book['series'] == 'Earthsea' }
      end

      it { expect(scope.debug).to be == inspected }

      it { expect(scope.call(data: data)).to be == matching }
    end

    describe '#or a complex scope' do
      let(:scope) { super().or(complex_scope) }
      let(:inspected) do
        <<~TEXT.strip
          Basic::ConjunctionScope (2):
          - Basic::CriteriaScope (1):
            - "published_at" greater_than "1973-01-01"
          - Basic::NegationScope (1):
            - Basic::CriteriaScope (1):
              - "series" equal nil
        TEXT
      end
      let(:matching) do
        super()
          .select { |book| book['published_at'] > '1973-01-01' }
          .reject { |book| book['series'].nil? }
      end

      it { expect(scope.debug).to be == inspected }

      it { expect(scope.call(data: data)).to be == matching }
    end

    describe '#not a block' do
      let(:block) { -> { { 'series' => 'Earthsea' } } }
      let(:scope) { super().not(&block) }
      let(:inspected) do
        <<~TEXT.strip
          Basic::ConjunctionScope (2):
          - Basic::CriteriaScope (0)
          - Basic::NegationScope (1):
            - Basic::CriteriaScope (1):
              - "series" equal "Earthsea"
        TEXT
      end
      let(:matching) do
        super().reject { |book| book['series'] == 'Earthsea' }
      end

      it { expect(scope.debug).to be == inspected }

      it { expect(scope.call(data: data)).to be == matching }
    end

    describe '#not a hash' do
      let(:value) { { 'series' => 'Earthsea' } }
      let(:scope) { super().not(value) }
      let(:inspected) do
        <<~TEXT.strip
          Basic::ConjunctionScope (2):
          - Basic::CriteriaScope (0)
          - Basic::NegationScope (1):
            - Basic::CriteriaScope (1):
              - "series" equal "Earthsea"
        TEXT
      end
      let(:matching) do
        super().reject { |book| book['series'] == 'Earthsea' }
      end

      it { expect(scope.debug).to be == inspected }

      it { expect(scope.call(data: data)).to be == matching }
    end

    describe '#not a basic scope' do
      let(:value) { Cuprum::Collections::Scope.new({ 'series' => 'Earthsea' }) }
      let(:scope) { super().not(value) }
      let(:inspected) do
        <<~TEXT.strip
          Basic::ConjunctionScope (2):
          - Basic::CriteriaScope (0)
          - Basic::NegationScope (1):
            - Basic::CriteriaScope (1):
              - "series" equal "Earthsea"
        TEXT
      end
      let(:matching) do
        super().reject { |book| book['series'] == 'Earthsea' }
      end

      it { expect(scope.debug).to be == inspected }

      it { expect(scope.call(data: data)).to be == matching }
    end

    describe '#not a complex scope' do
      let(:scope) { super().not(complex_scope) }
      let(:inspected) do
        <<~TEXT.strip
          Basic::ConjunctionScope (2):
          - Basic::CriteriaScope (0)
          - Basic::NegationScope (2):
            - Basic::CriteriaScope (1):
              - "published_at" greater_than "1973-01-01"
            - Basic::NegationScope (1):
              - Basic::CriteriaScope (1):
                - "series" equal nil
        TEXT
      end
      let(:matching) do
        super().reject do |book|
          book['published_at'] > '1973-01-01' && !book['series'].nil?
        end
      end

      it { expect(scope.debug).to be == inspected }

      it { expect(scope.call(data: data)).to be == matching }
    end
  end

  describe 'with an all scope' do
    let(:scope)     { described_class::AllScope.new }
    let(:inspected) { 'Basic::AllScope' }
    let(:matching)  { data }

    it { expect(scope.debug).to be == inspected }

    it { expect(scope.call(data: data)).to be == matching }

    describe '#and a block' do
      let(:block) { -> { { 'series' => 'Earthsea' } } }
      let(:scope) { super().and(&block) }
      let(:inspected) do
        <<~TEXT.strip
          Basic::CriteriaScope (1):
          - "series" equal "Earthsea"
        TEXT
      end
      let(:matching) do
        super().select { |book| book['series'] == 'Earthsea' }
      end

      it { expect(scope.debug).to be == inspected }

      it { expect(scope.call(data: data)).to be == matching }
    end

    describe '#and a hash' do
      let(:value) { { 'series' => 'Earthsea' } }
      let(:scope) { super().and(value) }
      let(:inspected) do
        <<~TEXT.strip
          Basic::CriteriaScope (1):
          - "series" equal "Earthsea"
        TEXT
      end
      let(:matching) do
        super().select { |book| book['series'] == 'Earthsea' }
      end

      it { expect(scope.debug).to be == inspected }

      it { expect(scope.call(data: data)).to be == matching }
    end

    describe '#and a basic scope' do
      let(:value) { Cuprum::Collections::Scope.new({ 'series' => 'Earthsea' }) }
      let(:scope) { super().and(value) }
      let(:inspected) do
        <<~TEXT.strip
          Basic::CriteriaScope (1):
          - "series" equal "Earthsea"
        TEXT
      end
      let(:matching) do
        super().select { |book| book['series'] == 'Earthsea' }
      end

      it { expect(scope.debug).to be == inspected }

      it { expect(scope.call(data: data)).to be == matching }
    end

    describe '#and a complex scope' do
      let(:scope) { super().and(complex_scope) }
      let(:inspected) do
        <<~TEXT.strip
          Basic::ConjunctionScope (2):
          - Basic::CriteriaScope (1):
            - "published_at" greater_than "1973-01-01"
          - Basic::NegationScope (1):
            - Basic::CriteriaScope (1):
              - "series" equal nil
        TEXT
      end
      let(:matching) do
        super()
          .select { |book| book['published_at'] > '1973-01-01' }
          .reject { |book| book['series'].nil? }
      end

      it { expect(scope.debug).to be == inspected }

      it { expect(scope.call(data: data)).to be == matching }
    end

    describe '#or a block' do
      let(:block) { -> { { 'series' => 'Earthsea' } } }
      let(:scope) { super().or(&block) }
      let(:inspected) do
        <<~TEXT.strip
          Basic::CriteriaScope (1):
          - "series" equal "Earthsea"
        TEXT
      end
      let(:matching) do
        super().select { |book| book['series'] == 'Earthsea' }
      end

      it { expect(scope.debug).to be == inspected }

      it { expect(scope.call(data: data)).to be == matching }
    end

    describe '#or a hash' do
      let(:value) { { 'series' => 'Earthsea' } }
      let(:scope) { super().or(value) }
      let(:inspected) do
        <<~TEXT.strip
          Basic::CriteriaScope (1):
          - "series" equal "Earthsea"
        TEXT
      end
      let(:matching) do
        super().select { |book| book['series'] == 'Earthsea' }
      end

      it { expect(scope.debug).to be == inspected }

      it { expect(scope.call(data: data)).to be == matching }
    end

    describe '#or a basic scope' do
      let(:value) { Cuprum::Collections::Scope.new({ 'series' => 'Earthsea' }) }
      let(:scope) { super().or(value) }
      let(:inspected) do
        <<~TEXT.strip
          Basic::CriteriaScope (1):
          - "series" equal "Earthsea"
        TEXT
      end
      let(:matching) do
        super().select { |book| book['series'] == 'Earthsea' }
      end

      it { expect(scope.debug).to be == inspected }

      it { expect(scope.call(data: data)).to be == matching }
    end

    describe '#or a complex scope' do
      let(:scope) { super().or(complex_scope) }
      let(:inspected) do
        <<~TEXT.strip
          Basic::ConjunctionScope (2):
          - Basic::CriteriaScope (1):
            - "published_at" greater_than "1973-01-01"
          - Basic::NegationScope (1):
            - Basic::CriteriaScope (1):
              - "series" equal nil
        TEXT
      end
      let(:matching) do
        super()
          .select { |book| book['published_at'] > '1973-01-01' }
          .reject { |book| book['series'].nil? }
      end

      it { expect(scope.debug).to be == inspected }

      it { expect(scope.call(data: data)).to be == matching }
    end

    describe '#not a block' do
      let(:block) { -> { { 'series' => 'Earthsea' } } }
      let(:scope) { super().not(&block) }
      let(:inspected) do
        <<~TEXT.strip
          Basic::NegationScope (1):
          - Basic::CriteriaScope (1):
            - "series" equal "Earthsea"
        TEXT
      end
      let(:matching) do
        super().reject { |book| book['series'] == 'Earthsea' }
      end

      it { expect(scope.debug).to be == inspected }

      it { expect(scope.call(data: data)).to be == matching }
    end

    describe '#not a hash' do
      let(:value) { { 'series' => 'Earthsea' } }
      let(:scope) { super().not(value) }
      let(:inspected) do
        <<~TEXT.strip
          Basic::NegationScope (1):
          - Basic::CriteriaScope (1):
            - "series" equal "Earthsea"
        TEXT
      end
      let(:matching) do
        super().reject { |book| book['series'] == 'Earthsea' }
      end

      it { expect(scope.debug).to be == inspected }

      it { expect(scope.call(data: data)).to be == matching }
    end

    describe '#not a basic scope' do
      let(:value) { Cuprum::Collections::Scope.new({ 'series' => 'Earthsea' }) }
      let(:scope) { super().not(value) }
      let(:inspected) do
        <<~TEXT.strip
          Basic::NegationScope (1):
          - Basic::CriteriaScope (1):
            - "series" equal "Earthsea"
        TEXT
      end
      let(:matching) do
        super().reject { |book| book['series'] == 'Earthsea' }
      end

      it { expect(scope.debug).to be == inspected }

      it { expect(scope.call(data: data)).to be == matching }
    end

    describe '#not a complex scope' do
      let(:scope) { super().not(complex_scope) }
      let(:inspected) do
        <<~TEXT.strip
          Basic::NegationScope (2):
          - Basic::CriteriaScope (1):
            - "published_at" greater_than "1973-01-01"
          - Basic::NegationScope (1):
            - Basic::CriteriaScope (1):
              - "series" equal nil
        TEXT
      end
      let(:matching) do
        super().reject do |book|
          book['published_at'] > '1973-01-01' && !book['series'].nil?
        end
      end

      it { expect(scope.debug).to be == inspected }

      it { expect(scope.call(data: data)).to be == matching }
    end
  end

  describe 'with a criteria scope' do
    let(:criteria) do
      operators = Cuprum::Collections::Queries::Operators

      [
        [
          'author',
          operators::EQUAL,
          'Ursula K. LeGuin'
        ]
      ]
    end
    let(:scope) { described_class::CriteriaScope.new(criteria: criteria) }
    let(:inspected) do
      <<~TEXT.strip
        Basic::CriteriaScope (1):
        - "author" equal "Ursula K. LeGuin"
      TEXT
    end
    let(:matching) do
      data.select { |book| book['author'] == 'Ursula K. LeGuin' }
    end

    it { expect(scope.debug).to be == inspected }

    it { expect(scope.call(data: data)).to be == matching }

    describe '#and a block' do
      let(:block) { -> { { 'series' => 'Earthsea' } } }
      let(:scope) { super().and(&block) }
      let(:inspected) do
        <<~TEXT.strip
          Basic::CriteriaScope (2):
          - "author" equal "Ursula K. LeGuin"
          - "series" equal "Earthsea"
        TEXT
      end
      let(:matching) do
        super().select { |book| book['series'] == 'Earthsea' }
      end

      it { expect(scope.debug).to be == inspected }

      it { expect(scope.call(data: data)).to be == matching }
    end

    describe '#and a hash' do
      let(:value) { { 'series' => 'Earthsea' } }
      let(:scope) { super().and(value) }
      let(:inspected) do
        <<~TEXT.strip
          Basic::CriteriaScope (2):
          - "author" equal "Ursula K. LeGuin"
          - "series" equal "Earthsea"
        TEXT
      end
      let(:matching) do
        super().select { |book| book['series'] == 'Earthsea' }
      end

      it { expect(scope.debug).to be == inspected }

      it { expect(scope.call(data: data)).to be == matching }
    end

    describe '#and a basic scope' do
      let(:value) do
        Cuprum::Collections::Scope.new({ 'series' => 'Earthsea' })
      end
      let(:scope) { super().and(value) }
      let(:inspected) do
        <<~TEXT.strip
          Basic::CriteriaScope (2):
          - "author" equal "Ursula K. LeGuin"
          - "series" equal "Earthsea"
        TEXT
      end
      let(:matching) do
        super().select { |book| book['series'] == 'Earthsea' }
      end

      it { expect(scope.debug).to be == inspected }

      it { expect(scope.call(data: data)).to be == matching }
    end

    describe '#and a complex scope' do
      let(:scope) { super().and(complex_scope) }
      let(:inspected) do
        <<~TEXT.strip
          Basic::ConjunctionScope (3):
          - Basic::CriteriaScope (1):
            - "author" equal "Ursula K. LeGuin"
          - Basic::CriteriaScope (1):
            - "published_at" greater_than "1973-01-01"
          - Basic::NegationScope (1):
            - Basic::CriteriaScope (1):
              - "series" equal nil
        TEXT
      end
      let(:matching) do
        super()
          .select { |book| book['published_at'] > '1973-01-01' }
          .reject { |book| book['series'].nil? }
      end

      it { expect(scope.debug).to be == inspected }

      it { expect(scope.call(data: data)).to be == matching }
    end

    describe '#or a block' do
      let(:block) { -> { { 'series' => 'Earthsea' } } }
      let(:scope) { super().or(&block) }
      let(:inspected) do
        <<~TEXT.strip
          Basic::DisjunctionScope (2):
          - Basic::CriteriaScope (1):
            - "author" equal "Ursula K. LeGuin"
          - Basic::CriteriaScope (1):
            - "series" equal "Earthsea"
        TEXT
      end

      it { expect(scope.debug).to be == inspected }

      it { expect(scope.call(data: data)).to be == matching }
    end

    describe '#or a hash' do
      let(:value) { { 'series' => 'Earthsea' } }
      let(:scope) { super().or(value) }
      let(:inspected) do
        <<~TEXT.strip
          Basic::DisjunctionScope (2):
          - Basic::CriteriaScope (1):
            - "author" equal "Ursula K. LeGuin"
          - Basic::CriteriaScope (1):
            - "series" equal "Earthsea"
        TEXT
      end

      it { expect(scope.debug).to be == inspected }

      it { expect(scope.call(data: data)).to be == matching }
    end

    describe '#or a basic scope' do
      let(:value) { Cuprum::Collections::Scope.new({ 'series' => 'Earthsea' }) }
      let(:scope) { super().or(value) }
      let(:inspected) do
        <<~TEXT.strip
          Basic::DisjunctionScope (2):
          - Basic::CriteriaScope (1):
            - "author" equal "Ursula K. LeGuin"
          - Basic::CriteriaScope (1):
            - "series" equal "Earthsea"
        TEXT
      end

      it { expect(scope.debug).to be == inspected }

      it { expect(scope.call(data: data)).to be == matching }
    end

    describe '#or a complex scope' do
      let(:scope) { super().or(complex_scope) }
      let(:inspected) do
        <<~TEXT.strip
          Basic::DisjunctionScope (2):
          - Basic::CriteriaScope (1):
            - "author" equal "Ursula K. LeGuin"
          - Basic::ConjunctionScope (2):
            - Basic::CriteriaScope (1):
              - "published_at" greater_than "1973-01-01"
            - Basic::NegationScope (1):
              - Basic::CriteriaScope (1):
                - "series" equal nil
        TEXT
      end

      it { expect(scope.debug).to be == inspected }

      it { expect(scope.call(data: data)).to be == matching }
    end

    describe '#not a block' do
      let(:block) { -> { { 'series' => 'Earthsea' } } }
      let(:scope) { super().not(&block) }
      let(:inspected) do
        <<~TEXT.strip
          Basic::ConjunctionScope (2):
          - Basic::CriteriaScope (1):
            - "author" equal "Ursula K. LeGuin"
          - Basic::NegationScope (1):
            - Basic::CriteriaScope (1):
              - "series" equal "Earthsea"
        TEXT
      end
      let(:matching) do
        super().reject { |book| book['series'] == 'Earthsea' }
      end

      it { expect(scope.debug).to be == inspected }

      it { expect(scope.call(data: data)).to be == matching }
    end

    describe '#not a hash' do
      let(:value) { { 'series' => 'Earthsea' } }
      let(:scope) { super().not(value) }
      let(:inspected) do
        <<~TEXT.strip
          Basic::ConjunctionScope (2):
          - Basic::CriteriaScope (1):
            - "author" equal "Ursula K. LeGuin"
          - Basic::NegationScope (1):
            - Basic::CriteriaScope (1):
              - "series" equal "Earthsea"
        TEXT
      end
      let(:matching) do
        super().reject { |book| book['series'] == 'Earthsea' }
      end

      it { expect(scope.debug).to be == inspected }

      it { expect(scope.call(data: data)).to be == matching }
    end

    describe '#not a basic scope' do
      let(:value) { Cuprum::Collections::Scope.new({ 'series' => 'Earthsea' }) }
      let(:scope) { super().not(value) }
      let(:inspected) do
        <<~TEXT.strip
          Basic::ConjunctionScope (2):
          - Basic::CriteriaScope (1):
            - "author" equal "Ursula K. LeGuin"
          - Basic::NegationScope (1):
            - Basic::CriteriaScope (1):
              - "series" equal "Earthsea"
        TEXT
      end
      let(:matching) do
        super().reject { |book| book['series'] == 'Earthsea' }
      end

      it { expect(scope.debug).to be == inspected }

      it { expect(scope.call(data: data)).to be == matching }
    end

    describe '#not a complex scope' do
      let(:scope) { super().not(complex_scope) }
      let(:inspected) do
        <<~TEXT.strip
          Basic::ConjunctionScope (2):
          - Basic::CriteriaScope (1):
            - "author" equal "Ursula K. LeGuin"
          - Basic::NegationScope (2):
            - Basic::CriteriaScope (1):
              - "published_at" greater_than "1973-01-01"
            - Basic::NegationScope (1):
              - Basic::CriteriaScope (1):
                - "series" equal nil
        TEXT
      end
      let(:matching) do
        super().reject do |book|
          book['published_at'] > '1973-01-01' && !book['series'].nil?
        end
      end

      it { expect(scope.debug).to be == inspected }

      it { expect(scope.call(data: data)).to be == matching }
    end
  end

  describe 'with a conjunction scope' do
    let(:scope) do
      described_class::CriteriaScope
        .new(criteria: [])
        .where({ 'author' => 'Ursula K. LeGuin' })
        .not({ 'title' => 'The Ones Who Walk Away From Omelas' })
    end
    let(:inspected) do
      <<~TEXT.strip
        Basic::ConjunctionScope (2):
        - Basic::CriteriaScope (1):
          - "author" equal "Ursula K. LeGuin"
        - Basic::NegationScope (1):
          - Basic::CriteriaScope (1):
            - "title" equal "The Ones Who Walk Away From Omelas"
      TEXT
    end
    let(:matching) do
      data
        .select { |book| book['author'] == 'Ursula K. LeGuin' }
        .reject { |book| book['title'] == 'The Ones Who Walk Away From Omelas' }
    end

    it { expect(scope.debug).to be == inspected }

    it { expect(scope.call(data: data)).to be == matching }

    describe '#and a block' do
      let(:block) { -> { { 'series' => 'Earthsea' } } }
      let(:scope) { super().and(&block) }
      let(:inspected) do
        <<~TEXT.strip
          Basic::ConjunctionScope (3):
          - Basic::CriteriaScope (1):
            - "author" equal "Ursula K. LeGuin"
          - Basic::NegationScope (1):
            - Basic::CriteriaScope (1):
              - "title" equal "The Ones Who Walk Away From Omelas"
          - Basic::CriteriaScope (1):
            - "series" equal "Earthsea"
        TEXT
      end
      let(:matching) do
        super().select { |book| book['series'] == 'Earthsea' }
      end

      it { expect(scope.debug).to be == inspected }

      it { expect(scope.call(data: data)).to be == matching }
    end

    describe '#and a hash' do
      let(:value) { { 'series' => 'Earthsea' } }
      let(:scope) { super().and(value) }
      let(:inspected) do
        <<~TEXT.strip
          Basic::ConjunctionScope (3):
          - Basic::CriteriaScope (1):
            - "author" equal "Ursula K. LeGuin"
          - Basic::NegationScope (1):
            - Basic::CriteriaScope (1):
              - "title" equal "The Ones Who Walk Away From Omelas"
          - Basic::CriteriaScope (1):
            - "series" equal "Earthsea"
        TEXT
      end
      let(:matching) do
        super().select { |book| book['series'] == 'Earthsea' }
      end

      it { expect(scope.debug).to be == inspected }

      it { expect(scope.call(data: data)).to be == matching }
    end

    describe '#and a basic scope' do
      let(:value) { Cuprum::Collections::Scope.new({ 'series' => 'Earthsea' }) }
      let(:scope) { super().and(value) }
      let(:inspected) do
        <<~TEXT.strip
          Basic::ConjunctionScope (3):
          - Basic::CriteriaScope (1):
            - "author" equal "Ursula K. LeGuin"
          - Basic::NegationScope (1):
            - Basic::CriteriaScope (1):
              - "title" equal "The Ones Who Walk Away From Omelas"
          - Basic::CriteriaScope (1):
            - "series" equal "Earthsea"
        TEXT
      end
      let(:matching) do
        super().select { |book| book['series'] == 'Earthsea' }
      end

      it { expect(scope.debug).to be == inspected }

      it { expect(scope.call(data: data)).to be == matching }
    end

    describe '#and a complex scope' do
      let(:scope) { super().and(complex_scope) }
      let(:inspected) do
        <<~TEXT.strip
          Basic::ConjunctionScope (4):
          - Basic::CriteriaScope (1):
            - "author" equal "Ursula K. LeGuin"
          - Basic::NegationScope (1):
            - Basic::CriteriaScope (1):
              - "title" equal "The Ones Who Walk Away From Omelas"
          - Basic::CriteriaScope (1):
            - "published_at" greater_than "1973-01-01"
          - Basic::NegationScope (1):
            - Basic::CriteriaScope (1):
              - "series" equal nil
        TEXT
      end
      let(:matching) do
        # :nocov:
        super()
          .select { |book| book['published_at'] > '1973-01-01' }
          .reject { |book| book['series'].nil? }
        # :nocov:
      end

      it { expect(scope.debug).to be == inspected }

      it { expect(scope.call(data: data)).to be == matching }
    end

    describe '#or a block' do
      let(:block) { -> { { 'series' => 'Earthsea' } } }
      let(:scope) { super().or(&block) }
      let(:inspected) do
        <<~TEXT.strip
          Basic::DisjunctionScope (2):
          - Basic::ConjunctionScope (2):
            - Basic::CriteriaScope (1):
              - "author" equal "Ursula K. LeGuin"
            - Basic::NegationScope (1):
              - Basic::CriteriaScope (1):
                - "title" equal "The Ones Who Walk Away From Omelas"
          - Basic::CriteriaScope (1):
            - "series" equal "Earthsea"
        TEXT
      end
      let(:matching) do
        [*super(), *data.select { |book| book['series'] == 'Earthsea' }].uniq
      end

      it { expect(scope.debug).to be == inspected }

      it { expect(scope.call(data: data)).to match_array(matching) }
    end

    describe '#or a hash' do
      let(:value) { { 'series' => 'Earthsea' } }
      let(:scope) { super().or(value) }
      let(:inspected) do
        <<~TEXT.strip
          Basic::DisjunctionScope (2):
          - Basic::ConjunctionScope (2):
            - Basic::CriteriaScope (1):
              - "author" equal "Ursula K. LeGuin"
            - Basic::NegationScope (1):
              - Basic::CriteriaScope (1):
                - "title" equal "The Ones Who Walk Away From Omelas"
          - Basic::CriteriaScope (1):
            - "series" equal "Earthsea"
        TEXT
      end
      let(:matching) do
        [*super(), *data.select { |book| book['series'] == 'Earthsea' }].uniq
      end

      it { expect(scope.debug).to be == inspected }

      it { expect(scope.call(data: data)).to match_array(matching) }
    end

    describe '#or a basic scope' do
      let(:value) { Cuprum::Collections::Scope.new({ 'series' => 'Earthsea' }) }
      let(:scope) { super().or(value) }
      let(:inspected) do
        <<~TEXT.strip
          Basic::DisjunctionScope (2):
          - Basic::ConjunctionScope (2):
            - Basic::CriteriaScope (1):
              - "author" equal "Ursula K. LeGuin"
            - Basic::NegationScope (1):
              - Basic::CriteriaScope (1):
                - "title" equal "The Ones Who Walk Away From Omelas"
          - Basic::CriteriaScope (1):
            - "series" equal "Earthsea"
        TEXT
      end
      let(:matching) do
        [*super(), *data.select { |book| book['series'] == 'Earthsea' }].uniq
      end

      it { expect(scope.debug).to be == inspected }

      it { expect(scope.call(data: data)).to match_array(matching) }
    end

    describe '#or a complex scope' do
      let(:value) { Cuprum::Collections::Scope.new({ 'series' => 'Earthsea' }) }
      let(:scope) { super().or(complex_scope) }
      let(:inspected) do
        <<~TEXT.strip
          Basic::DisjunctionScope (2):
          - Basic::ConjunctionScope (2):
            - Basic::CriteriaScope (1):
              - "author" equal "Ursula K. LeGuin"
            - Basic::NegationScope (1):
              - Basic::CriteriaScope (1):
                - "title" equal "The Ones Who Walk Away From Omelas"
          - Basic::ConjunctionScope (2):
            - Basic::CriteriaScope (1):
              - "published_at" greater_than "1973-01-01"
            - Basic::NegationScope (1):
              - Basic::CriteriaScope (1):
                - "series" equal nil
        TEXT
      end
      let(:matching) do
        [
          *super(),
          *data
            .select { |book| book['published_at'] > '1973-01-01' }
            .reject { |book| book['series'].nil? }
        ].uniq
      end

      it { expect(scope.debug).to be == inspected }

      it { expect(scope.call(data: data)).to match_array(matching) }
    end

    describe '#not a block' do
      let(:block) { -> { { 'series' => 'Earthsea' } } }
      let(:scope) { super().not(&block) }
      let(:inspected) do
        <<~TEXT.strip
          Basic::ConjunctionScope (3):
          - Basic::CriteriaScope (1):
            - "author" equal "Ursula K. LeGuin"
          - Basic::NegationScope (1):
            - Basic::CriteriaScope (1):
              - "title" equal "The Ones Who Walk Away From Omelas"
          - Basic::NegationScope (1):
            - Basic::CriteriaScope (1):
              - "series" equal "Earthsea"
        TEXT
      end
      let(:matching) do
        super().reject { |book| book['series'] == 'Earthsea' }
      end

      it { expect(scope.debug).to be == inspected }

      it { expect(scope.call(data: data)).to be == matching }
    end

    describe '#not a hash' do
      let(:value) { { 'series' => 'Earthsea' } }
      let(:scope) { super().not(value) }
      let(:inspected) do
        <<~TEXT.strip
          Basic::ConjunctionScope (3):
          - Basic::CriteriaScope (1):
            - "author" equal "Ursula K. LeGuin"
          - Basic::NegationScope (1):
            - Basic::CriteriaScope (1):
              - "title" equal "The Ones Who Walk Away From Omelas"
          - Basic::NegationScope (1):
            - Basic::CriteriaScope (1):
              - "series" equal "Earthsea"
        TEXT
      end
      let(:matching) do
        super().reject { |book| book['series'] == 'Earthsea' }
      end

      it { expect(scope.debug).to be == inspected }

      it { expect(scope.call(data: data)).to be == matching }
    end

    describe '#not a basic scope' do
      let(:value) { Cuprum::Collections::Scope.new({ 'series' => 'Earthsea' }) }
      let(:scope) { super().not(value) }
      let(:inspected) do
        <<~TEXT.strip
          Basic::ConjunctionScope (3):
          - Basic::CriteriaScope (1):
            - "author" equal "Ursula K. LeGuin"
          - Basic::NegationScope (1):
            - Basic::CriteriaScope (1):
              - "title" equal "The Ones Who Walk Away From Omelas"
          - Basic::NegationScope (1):
            - Basic::CriteriaScope (1):
              - "series" equal "Earthsea"
        TEXT
      end
      let(:matching) do
        super().reject { |book| book['series'] == 'Earthsea' }
      end

      it { expect(scope.debug).to be == inspected }

      it { expect(scope.call(data: data)).to be == matching }
    end

    describe '#not a complex scope' do
      let(:scope) { super().not(complex_scope) }
      let(:inspected) do
        <<~TEXT.strip
          Basic::ConjunctionScope (3):
          - Basic::CriteriaScope (1):
            - "author" equal "Ursula K. LeGuin"
          - Basic::NegationScope (1):
            - Basic::CriteriaScope (1):
              - "title" equal "The Ones Who Walk Away From Omelas"
          - Basic::NegationScope (2):
            - Basic::CriteriaScope (1):
              - "published_at" greater_than "1973-01-01"
            - Basic::NegationScope (1):
              - Basic::CriteriaScope (1):
                - "series" equal nil
        TEXT
      end
      let(:matching) do
        super().reject do |book|
          book['published_at'] > '1973-01-01' && !book['series'].nil?
        end
      end

      it { expect(scope.debug).to be == inspected }

      it { expect(scope.call(data: data)).to be == matching }
    end
  end

  describe 'with a disjunction scope' do
    let(:scope) do
      described_class::CriteriaScope
        .new(criteria: [])
        .where({ 'author' => 'Ursula K. LeGuin' })
        .or({ 'title' => 'The Silmarillion' })
    end
    let(:inspected) do
      <<~TEXT.strip
        Basic::DisjunctionScope (2):
        - Basic::CriteriaScope (1):
          - "author" equal "Ursula K. LeGuin"
        - Basic::CriteriaScope (1):
          - "title" equal "The Silmarillion"
      TEXT
    end
    let(:matching) do
      data
        .select { |book| book['author'] == 'Ursula K. LeGuin' }
        .then do |ary|
          ary << data.find { |book| book['title'] == 'The Silmarillion' }
        end
    end

    it { expect(scope.debug).to be == inspected }

    it { expect(scope.call(data: data)).to match_array(matching) }

    describe '#and a block' do
      let(:block) { -> { { 'series' => 'Earthsea' } } }
      let(:scope) { super().and(&block) }
      let(:inspected) do
        <<~TEXT.strip
          Basic::ConjunctionScope (2):
          - Basic::DisjunctionScope (2):
            - Basic::CriteriaScope (1):
              - "author" equal "Ursula K. LeGuin"
            - Basic::CriteriaScope (1):
              - "title" equal "The Silmarillion"
          - Basic::CriteriaScope (1):
            - "series" equal "Earthsea"
        TEXT
      end
      let(:matching) do
        super().select { |book| book['series'] == 'Earthsea' }
      end

      it { expect(scope.debug).to be == inspected }

      it { expect(scope.call(data: data)).to be == matching }
    end

    describe '#and a hash' do
      let(:value) { { 'series' => 'Earthsea' } }
      let(:scope) { super().and(value) }
      let(:inspected) do
        <<~TEXT.strip
          Basic::ConjunctionScope (2):
          - Basic::DisjunctionScope (2):
            - Basic::CriteriaScope (1):
              - "author" equal "Ursula K. LeGuin"
            - Basic::CriteriaScope (1):
              - "title" equal "The Silmarillion"
          - Basic::CriteriaScope (1):
            - "series" equal "Earthsea"
        TEXT
      end
      let(:matching) do
        super().select { |book| book['series'] == 'Earthsea' }
      end

      it { expect(scope.debug).to be == inspected }

      it { expect(scope.call(data: data)).to be == matching }
    end

    describe '#and a basic scope' do
      let(:value) { Cuprum::Collections::Scope.new({ 'series' => 'Earthsea' }) }
      let(:scope) { super().and(value) }
      let(:inspected) do
        <<~TEXT.strip
          Basic::ConjunctionScope (2):
          - Basic::DisjunctionScope (2):
            - Basic::CriteriaScope (1):
              - "author" equal "Ursula K. LeGuin"
            - Basic::CriteriaScope (1):
              - "title" equal "The Silmarillion"
          - Basic::CriteriaScope (1):
            - "series" equal "Earthsea"
        TEXT
      end
      let(:matching) do
        super().select { |book| book['series'] == 'Earthsea' }
      end

      it { expect(scope.debug).to be == inspected }

      it { expect(scope.call(data: data)).to be == matching }
    end

    describe '#and_a_complex_scope' do
      let(:scope) { super().and(complex_scope) }
      let(:inspected) do
        <<~TEXT.strip
          Basic::ConjunctionScope (3):
          - Basic::DisjunctionScope (2):
            - Basic::CriteriaScope (1):
              - "author" equal "Ursula K. LeGuin"
            - Basic::CriteriaScope (1):
              - "title" equal "The Silmarillion"
          - Basic::CriteriaScope (1):
            - "published_at" greater_than "1973-01-01"
          - Basic::NegationScope (1):
            - Basic::CriteriaScope (1):
              - "series" equal nil
        TEXT
      end
      let(:matching) do
        super()
          .select { |book| book['published_at'] > '1973-01-01' }
          .reject { |book| book['series'].nil? }
      end

      it { expect(scope.debug).to be == inspected }

      it { expect(scope.call(data: data)).to match_array(matching) }
    end

    describe '#or a block' do
      let(:block) { -> { { 'series' => 'Earthsea' } } }
      let(:scope) { super().or(&block) }
      let(:inspected) do
        <<~TEXT.strip
          Basic::DisjunctionScope (3):
          - Basic::CriteriaScope (1):
            - "author" equal "Ursula K. LeGuin"
          - Basic::CriteriaScope (1):
            - "title" equal "The Silmarillion"
          - Basic::CriteriaScope (1):
            - "series" equal "Earthsea"
        TEXT
      end

      it { expect(scope.debug).to be == inspected }

      it { expect(scope.call(data: data)).to match_array(matching) }
    end

    describe '#or a hash' do
      let(:value) { { 'series' => 'Earthsea' } }
      let(:scope) { super().or(value) }
      let(:inspected) do
        <<~TEXT.strip
          Basic::DisjunctionScope (3):
          - Basic::CriteriaScope (1):
            - "author" equal "Ursula K. LeGuin"
          - Basic::CriteriaScope (1):
            - "title" equal "The Silmarillion"
          - Basic::CriteriaScope (1):
            - "series" equal "Earthsea"
        TEXT
      end

      it { expect(scope.debug).to be == inspected }

      it { expect(scope.call(data: data)).to match_array(matching) }
    end

    describe '#or a basic scope' do
      let(:value) { Cuprum::Collections::Scope.new({ 'series' => 'Earthsea' }) }
      let(:scope) { super().or(value) }
      let(:inspected) do
        <<~TEXT.strip
          Basic::DisjunctionScope (3):
          - Basic::CriteriaScope (1):
            - "author" equal "Ursula K. LeGuin"
          - Basic::CriteriaScope (1):
            - "title" equal "The Silmarillion"
          - Basic::CriteriaScope (1):
            - "series" equal "Earthsea"
        TEXT
      end

      it { expect(scope.debug).to be == inspected }

      it { expect(scope.call(data: data)).to match_array(matching) }
    end

    describe '#or a complex scope' do
      let(:scope) { super().or(complex_scope) }
      let(:inspected) do
        <<~TEXT.strip
          Basic::DisjunctionScope (3):
          - Basic::CriteriaScope (1):
            - "author" equal "Ursula K. LeGuin"
          - Basic::CriteriaScope (1):
            - "title" equal "The Silmarillion"
          - Basic::ConjunctionScope (2):
            - Basic::CriteriaScope (1):
              - "published_at" greater_than "1973-01-01"
            - Basic::NegationScope (1):
              - Basic::CriteriaScope (1):
                - "series" equal nil
        TEXT
      end
      let(:matching) do
        [
          *super(),
          *data
            .select { |book| book['published_at'] > '1973-01-01' }
            .reject { |book| book['series'].nil? }
        ].uniq
      end

      it { expect(scope.debug).to be == inspected }

      it { expect(scope.call(data: data)).to match_array(matching) }
    end

    describe '#not a block' do
      let(:block) { -> { { 'series' => 'Earthsea' } } }
      let(:scope) { super().not(&block) }
      let(:inspected) do
        <<~TEXT.strip
          Basic::ConjunctionScope (2):
          - Basic::DisjunctionScope (2):
            - Basic::CriteriaScope (1):
              - "author" equal "Ursula K. LeGuin"
            - Basic::CriteriaScope (1):
              - "title" equal "The Silmarillion"
          - Basic::NegationScope (1):
            - Basic::CriteriaScope (1):
              - "series" equal "Earthsea"
        TEXT
      end
      let(:matching) do
        super().reject { |book| book['series'] == 'Earthsea' }
      end

      it { expect(scope.debug).to be == inspected }

      it { expect(scope.call(data: data)).to match_array(matching) }
    end

    describe '#not a hash' do
      let(:value) { { 'series' => 'Earthsea' } }
      let(:scope) { super().not(value) }
      let(:inspected) do
        <<~TEXT.strip
          Basic::ConjunctionScope (2):
          - Basic::DisjunctionScope (2):
            - Basic::CriteriaScope (1):
              - "author" equal "Ursula K. LeGuin"
            - Basic::CriteriaScope (1):
              - "title" equal "The Silmarillion"
          - Basic::NegationScope (1):
            - Basic::CriteriaScope (1):
              - "series" equal "Earthsea"
        TEXT
      end
      let(:matching) do
        super().reject { |book| book['series'] == 'Earthsea' }
      end

      it { expect(scope.debug).to be == inspected }

      it { expect(scope.call(data: data)).to match_array(matching) }
    end

    describe '#not a basic scope' do
      let(:value) { Cuprum::Collections::Scope.new({ 'series' => 'Earthsea' }) }
      let(:scope) { super().not(value) }
      let(:inspected) do
        <<~TEXT.strip
          Basic::ConjunctionScope (2):
          - Basic::DisjunctionScope (2):
            - Basic::CriteriaScope (1):
              - "author" equal "Ursula K. LeGuin"
            - Basic::CriteriaScope (1):
              - "title" equal "The Silmarillion"
          - Basic::NegationScope (1):
            - Basic::CriteriaScope (1):
              - "series" equal "Earthsea"
        TEXT
      end
      let(:matching) do
        super().reject { |book| book['series'] == 'Earthsea' }
      end

      it { expect(scope.debug).to be == inspected }

      it { expect(scope.call(data: data)).to match_array(matching) }
    end

    describe '#not a complex scope' do
      let(:scope) { super().not(complex_scope) }
      let(:inspected) do
        <<~TEXT.strip
          Basic::ConjunctionScope (2):
          - Basic::DisjunctionScope (2):
            - Basic::CriteriaScope (1):
              - "author" equal "Ursula K. LeGuin"
            - Basic::CriteriaScope (1):
              - "title" equal "The Silmarillion"
          - Basic::NegationScope (2):
            - Basic::CriteriaScope (1):
              - "published_at" greater_than "1973-01-01"
            - Basic::NegationScope (1):
              - Basic::CriteriaScope (1):
                - "series" equal nil
        TEXT
      end
      let(:matching) do
        super().reject do |book|
          book['published_at'] > '1973-01-01' && !book['series'].nil?
        end
      end

      it { expect(scope.debug).to be == inspected }

      it { expect(scope.call(data: data)).to match_array(matching) }
    end
  end

  describe 'with a negation scope' do
    let(:criteria) do
      operators = Cuprum::Collections::Queries::Operators

      [
        [
          'author',
          operators::EQUAL,
          'J.R.R. Tolkien'
        ]
      ]
    end
    let(:scope) do
      wrapped = described_class::CriteriaScope.new(criteria: criteria)

      described_class::NegationScope.new(scopes: [wrapped])
    end
    let(:inspected) do
      <<~TEXT.strip
        Basic::NegationScope (1):
        - Basic::CriteriaScope (1):
          - "author" equal "J.R.R. Tolkien"
      TEXT
    end
    let(:matching) do
      data
        .reject { |book| book['author'] == 'J.R.R. Tolkien' }
    end

    it { expect(scope.debug).to be == inspected }

    it { expect(scope.call(data: data)).to match_array(matching) }

    describe '#and a block' do
      let(:block) { -> { { 'series' => 'Earthsea' } } }
      let(:scope) { super().and(&block) }
      let(:inspected) do
        <<~TEXT.strip
          Basic::ConjunctionScope (2):
          - Basic::NegationScope (1):
            - Basic::CriteriaScope (1):
              - "author" equal "J.R.R. Tolkien"
          - Basic::CriteriaScope (1):
            - "series" equal "Earthsea"
        TEXT
      end
      let(:matching) do
        super().select { |book| book['series'] == 'Earthsea' }
      end

      it { expect(scope.debug).to be == inspected }

      it { expect(scope.call(data: data)).to be == matching }
    end

    describe '#and a hash' do
      let(:value) { { 'series' => 'Earthsea' } }
      let(:scope) { super().and(value) }
      let(:inspected) do
        <<~TEXT.strip
          Basic::ConjunctionScope (2):
          - Basic::NegationScope (1):
            - Basic::CriteriaScope (1):
              - "author" equal "J.R.R. Tolkien"
          - Basic::CriteriaScope (1):
            - "series" equal "Earthsea"
        TEXT
      end
      let(:matching) do
        super().select { |book| book['series'] == 'Earthsea' }
      end

      it { expect(scope.debug).to be == inspected }

      it { expect(scope.call(data: data)).to be == matching }
    end

    describe '#and a basic scope' do
      let(:value) { Cuprum::Collections::Scope.new({ 'series' => 'Earthsea' }) }
      let(:scope) { super().and(value) }
      let(:inspected) do
        <<~TEXT.strip
          Basic::ConjunctionScope (2):
          - Basic::NegationScope (1):
            - Basic::CriteriaScope (1):
              - "author" equal "J.R.R. Tolkien"
          - Basic::CriteriaScope (1):
            - "series" equal "Earthsea"
        TEXT
      end
      let(:matching) do
        super().select { |book| book['series'] == 'Earthsea' }
      end

      it { expect(scope.debug).to be == inspected }

      it { expect(scope.call(data: data)).to be == matching }
    end

    describe '#and a complex scope' do
      let(:scope) { super().and(complex_scope) }
      let(:inspected) do
        <<~TEXT.strip
          Basic::ConjunctionScope (3):
          - Basic::NegationScope (1):
            - Basic::CriteriaScope (1):
              - "author" equal "J.R.R. Tolkien"
          - Basic::CriteriaScope (1):
            - "published_at" greater_than "1973-01-01"
          - Basic::NegationScope (1):
            - Basic::CriteriaScope (1):
              - "series" equal nil
        TEXT
      end
      let(:matching) do
        super().select do |book|
          book['published_at'] > '1973-01-01' && !book['series'].nil?
        end
      end

      it { expect(scope.debug).to be == inspected }

      it { expect(scope.call(data: data)).to be == matching }
    end

    describe '#or a block' do
      let(:block) { -> { { 'series' => 'Earthsea' } } }
      let(:scope) { super().or(&block) }
      let(:inspected) do
        <<~TEXT.strip
          Basic::DisjunctionScope (2):
          - Basic::NegationScope (1):
            - Basic::CriteriaScope (1):
              - "author" equal "J.R.R. Tolkien"
          - Basic::CriteriaScope (1):
            - "series" equal "Earthsea"
        TEXT
      end
      let(:matching) do
        [
          *super(),
          *data.select { |book| book['series'] == 'Earthsea' }
        ].uniq
      end

      it { expect(scope.debug).to be == inspected }

      it { expect(scope.call(data: data)).to match_array(matching) }
    end

    describe '#or a hash' do
      let(:value) { { 'series' => 'Earthsea' } }
      let(:scope) { super().or(value) }
      let(:inspected) do
        <<~TEXT.strip
          Basic::DisjunctionScope (2):
          - Basic::NegationScope (1):
            - Basic::CriteriaScope (1):
              - "author" equal "J.R.R. Tolkien"
          - Basic::CriteriaScope (1):
            - "series" equal "Earthsea"
        TEXT
      end
      let(:matching) do
        [
          *super(),
          *data.select { |book| book['series'] == 'Earthsea' }
        ].uniq
      end

      it { expect(scope.debug).to be == inspected }

      it { expect(scope.call(data: data)).to match_array(matching) }
    end

    describe '#or a basic scope' do
      let(:value) { Cuprum::Collections::Scope.new({ 'series' => 'Earthsea' }) }
      let(:scope) { super().or(value) }
      let(:inspected) do
        <<~TEXT.strip
          Basic::DisjunctionScope (2):
          - Basic::NegationScope (1):
            - Basic::CriteriaScope (1):
              - "author" equal "J.R.R. Tolkien"
          - Basic::CriteriaScope (1):
            - "series" equal "Earthsea"
        TEXT
      end
      let(:matching) do
        [
          *super(),
          *data.select { |book| book['series'] == 'Earthsea' }
        ].uniq
      end

      it { expect(scope.debug).to be == inspected }

      it { expect(scope.call(data: data)).to match_array(matching) }
    end

    describe '#or a complex scope' do
      let(:scope) { super().or(complex_scope) }
      let(:inspected) do
        <<~TEXT.strip
          Basic::DisjunctionScope (2):
          - Basic::NegationScope (1):
            - Basic::CriteriaScope (1):
              - "author" equal "J.R.R. Tolkien"
          - Basic::ConjunctionScope (2):
            - Basic::CriteriaScope (1):
              - "published_at" greater_than "1973-01-01"
            - Basic::NegationScope (1):
              - Basic::CriteriaScope (1):
                - "series" equal nil
        TEXT
      end
      let(:matching) do
        [
          *super(),
          *data
            .select { |book| book['published_at'] > '1973-01-01' }
            .reject { |book| book['series'].nil? }
        ].uniq
      end

      it { expect(scope.debug).to be == inspected }

      it { expect(scope.call(data: data)).to be == matching }
    end

    describe '#not a block' do
      let(:block) { -> { { 'series' => 'Earthsea' } } }
      let(:scope) { super().not(&block) }
      let(:inspected) do
        <<~TEXT.strip
          Basic::ConjunctionScope (2):
          - Basic::NegationScope (1):
            - Basic::CriteriaScope (1):
              - "author" equal "J.R.R. Tolkien"
          - Basic::NegationScope (1):
            - Basic::CriteriaScope (1):
              - "series" equal "Earthsea"
        TEXT
      end
      let(:matching) do
        super().reject { |book| book['series'] == 'Earthsea' }
      end

      it { expect(scope.debug).to be == inspected }

      it { expect(scope.call(data: data)).to be == matching }
    end

    describe '#not a hash' do
      let(:value) { { 'series' => 'Earthsea' } }
      let(:scope) { super().not(value) }
      let(:inspected) do
        <<~TEXT.strip
          Basic::ConjunctionScope (2):
          - Basic::NegationScope (1):
            - Basic::CriteriaScope (1):
              - "author" equal "J.R.R. Tolkien"
          - Basic::NegationScope (1):
            - Basic::CriteriaScope (1):
              - "series" equal "Earthsea"
        TEXT
      end
      let(:matching) do
        super().reject { |book| book['series'] == 'Earthsea' }
      end

      it { expect(scope.debug).to be == inspected }

      it { expect(scope.call(data: data)).to be == matching }
    end

    describe '#not a basic scope' do
      let(:value) { Cuprum::Collections::Scope.new({ 'series' => 'Earthsea' }) }
      let(:scope) { super().not(value) }
      let(:inspected) do
        <<~TEXT.strip
          Basic::ConjunctionScope (2):
          - Basic::NegationScope (1):
            - Basic::CriteriaScope (1):
              - "author" equal "J.R.R. Tolkien"
          - Basic::NegationScope (1):
            - Basic::CriteriaScope (1):
              - "series" equal "Earthsea"
        TEXT
      end
      let(:matching) do
        super().reject { |book| book['series'] == 'Earthsea' }
      end

      it { expect(scope.debug).to be == inspected }

      it { expect(scope.call(data: data)).to be == matching }
    end

    describe '#not a complex scope' do
      let(:scope) { super().not(complex_scope) }
      let(:inspected) do
        <<~TEXT.strip
          Basic::ConjunctionScope (2):
          - Basic::NegationScope (1):
            - Basic::CriteriaScope (1):
              - "author" equal "J.R.R. Tolkien"
          - Basic::NegationScope (2):
            - Basic::CriteriaScope (1):
              - "published_at" greater_than "1973-01-01"
            - Basic::NegationScope (1):
              - Basic::CriteriaScope (1):
                - "series" equal nil
        TEXT
      end
      let(:matching) do
        super().reject do |book|
          book['published_at'] > '1973-01-01' && !book['series'].nil?
        end
      end

      it { expect(scope.debug).to be == inspected }

      it { expect(scope.call(data: data)).to be == matching }
    end
  end
end
