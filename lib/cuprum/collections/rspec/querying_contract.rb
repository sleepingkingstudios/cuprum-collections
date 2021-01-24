# frozen_string_literal: true

require 'cuprum/collections/rspec'

module Cuprum::Collections::RSpec
  OPERATORS = Cuprum::Collections::Queries::Operators
  private_constant :OPERATORS

  # Shared contexts for specs that define querying behavior.
  QUERYING_CONTEXTS = lambda do
    let(:arguments) { [] }
    let(:block)     { nil }
    let(:keywords)  { {} }
    let(:strategy)  { nil }
    let(:limit)     { nil }
    let(:offset)    { nil }
    let(:order)     { nil }

    shared_context 'when the query has limit: value' do
      let(:limit)         { 3 }
      let(:matching_data) { super()[0...limit] }
    end

    shared_context 'when the query has offset: value' do
      let(:offset)        { 2 }
      let(:matching_data) { super()[offset..-1] || [] }
    end

    shared_context 'when the query has order: a simple ordering' do
      let(:order)         { :title }
      let(:matching_data) { super().sort_by { |item| item['title'] } }
    end

    shared_context 'when the query has order: a complex ordering' do
      let(:order) do
        {
          author: :asc,
          title:  :desc
        }
      end
      let(:matching_data) do
        super().sort do |u, v|
          cmp = u['author'] <=> v['author']

          cmp.zero? ? (v['title'] <=> u['title']) : cmp
        end
      end
    end

    shared_context 'when the query has where: a simple block filter' do
      let(:block) { -> { { author: 'Ursula K. LeGuin' } } }
      let(:matching_data) do
        super().select { |item| item['author'] == 'Ursula K. LeGuin' }
      end
    end

    shared_context 'when the query has where: a complex block filter' do
      let(:block) do
        lambda do
          {
            author: equals('Ursula K. LeGuin'),
            series: not_equal('Earthsea')
          }
        end
      end
      let(:matching_data) do
        super()
          .select { |item| item['author'] == 'Ursula K. LeGuin' }
          .reject { |item| item['series'] == 'Earthsea' }
      end
    end

    shared_context 'when the query has where: an equal block filter' do
      let(:block) { -> { { author: equals('Ursula K. LeGuin') } } }
      let(:matching_data) do
        super().select { |item| item['author'] == 'Ursula K. LeGuin' }
      end
    end

    shared_context 'when the query has where: a not_equal block filter' do
      let(:block) { -> { { author: not_equal('Ursula K. LeGuin') } } }
      let(:matching_data) do
        super().reject { |item| item['author'] == 'Ursula K. LeGuin' }
      end
    end

    shared_context 'when the query has multiple query options' do
      let(:arguments) { [] }
      let(:block)     { -> { { author: 'Ursula K. LeGuin' } } }
      let(:keywords)  { {} }
      let(:strategy)  { nil }
      let(:order)     { { title: :desc } }
      let(:limit)     { 2 }
      let(:offset)    { 1 }
      let(:matching_data) do
        super()
          .select { |item| item['author'] == 'Ursula K. LeGuin' }
          .sort { |u, v| v['title'] <=> u['title'] }
          .slice(1, 2) || []
      end
    end
  end

  # Contract validating the behavior objects that perform queries.
  QUERYING_CONTRACT = lambda do |block:, operators: OPERATORS.values|
    wrap_context 'when the query has limit: value' do
      instance_exec(&block)
    end

    wrap_context 'when the query has offset: value' do
      instance_exec(&block)
    end

    wrap_context 'when the query has order: a simple ordering' do
      instance_exec(&block)
    end

    wrap_context 'when the query has order: a complex ordering' do
      instance_exec(&block)
    end

    context 'when the query has where: a block filter' do
      context 'with a simple filter' do
        include_context 'when the query has where: a simple block filter'

        instance_exec(&block)
      end

      context 'with a complex filter' do
        include_context 'when the query has where: a complex block filter'

        if operators.include?(OPERATORS::EQUAL) &&
           operators.include?(OPERATORS::NOT_EQUAL)
          instance_exec(&block)
        else
          # :nocov:
          pending
          # :nocov:
        end
      end

      context 'with an equals filter' do
        include_context 'when the query has where: an equal block filter'

        if operators.include?(OPERATORS::EQUAL)
          instance_exec(&block)
        else
          # :nocov:
          pending
          # :nocov:
        end
      end

      context 'with a not_equal filter' do
        include_context 'when the query has where: a not_equal block filter'

        if operators.include?(OPERATORS::NOT_EQUAL)
          instance_exec(&block)
        else
          # :nocov:
          pending
          # :nocov:
        end
      end
    end

    wrap_context 'when the query has multiple query options' do
      instance_exec(&block)
    end
  end
end
