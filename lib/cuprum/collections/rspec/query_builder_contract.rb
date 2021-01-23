# frozen_string_literal: true

require 'cuprum/collections/rspec'

module Cuprum::Collections::RSpec
  # Contract validating the behavior of a QueryBuilder implementation.
  QUERY_BUILDER_CONTRACT = lambda do
    describe '#base_query' do
      include_examples 'should define reader', :base_query, -> { base_query }
    end

    describe '#call' do
      let(:criteria)  { [['title', :eq, 'The Naked Sun']] }
      let(:expected)  { criteria }
      let(:arguments) { %w[ichi ni san] }
      let(:keywords)  { { one: 1, two: 2, three: 3 } }
      let(:block)     { -> {} }
      let(:strategy)  { :custom }
      let(:parameters) do
        {
          arguments: arguments,
          block:     block,
          keywords:  keywords
        }
      end
      let(:parser) do
        instance_double(
          Cuprum::Collections::Queries::Parse,
          call: Cuprum::Result.new(value: criteria)
        )
      end
      let(:query) do
        builder.call(*arguments, strategy: strategy, **keywords, &block)
      end

      before(:example) do
        allow(Cuprum::Collections::Queries::Parse)
          .to receive(:new)
          .and_return(parser)
      end

      it 'should define the method' do
        expect(builder).to respond_to(:call)
          .with_unlimited_arguments
          .and_keywords(:strategy)
          .and_any_keywords
          .and_a_block
      end

      it 'should parse the criteria' do
        builder.call(*arguments, strategy: strategy, **keywords, &block)

        expect(parser)
          .to have_received(:call)
          .with(strategy: strategy, **parameters)
      end

      it { expect(query).to be_a base_query.class }

      it { expect(query).not_to be base_query }

      it { expect(query.criteria).to be == expected }

      context 'when the query has existing criteria' do
        let(:old_criteria) { [['genre', :eq, 'Science Fiction']] }
        let(:expected)     { old_criteria + criteria }
        let(:base_query)   { super().send(:with_criteria, old_criteria) }

        it { expect(query.criteria).to be == expected }
      end

      context 'when the parser is unable to parse the query' do
        let(:error)  { Cuprum::Error.new(message: 'Something went wrong.') }
        let(:result) { Cuprum::Result.new(error: error) }

        before(:example) do
          allow(parser).to receive(:call).and_return(result)
        end

        it 'should raise an exception' do
          expect do
            builder.call(*arguments, strategy: strategy, **keywords, &block)
          end
            .to raise_error Cuprum::Collections::QueryBuilder::ParseError,
              error.message
        end
      end
    end
  end
end
