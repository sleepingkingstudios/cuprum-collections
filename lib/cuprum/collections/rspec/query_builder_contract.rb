# frozen_string_literal: true

require 'cuprum/collections/rspec'

module Cuprum::Collections::RSpec
  # Contract validating the behavior of a QueryBuilder implementation.
  QUERY_BUILDER_CONTRACT = lambda do
    describe '#base_query' do
      include_examples 'should define reader', :base_query, -> { base_query }
    end

    describe '#call' do
      let(:criteria)  { [['title', :equal, 'The Naked Sun']] }
      let(:expected)  { criteria }
      let(:filter)    { { title: 'The Naked Sun' } }
      let(:strategy)  { :custom }
      let(:parser) do
        instance_double(
          Cuprum::Collections::Queries::Parse,
          call: Cuprum::Result.new(value: criteria)
        )
      end
      let(:query) do
        builder.call(strategy: strategy, where: filter)
      end

      before(:example) do
        allow(Cuprum::Collections::Queries::Parse)
          .to receive(:new)
          .and_return(parser)
      end

      it 'should define the method' do
        expect(builder).to respond_to(:call)
          .with(0).arguments
          .and_keywords(:strategy, :where)
      end

      it 'should parse the criteria' do
        builder.call(strategy: strategy, where: filter)

        expect(parser)
          .to have_received(:call)
          .with(strategy: strategy, where: filter)
      end

      it { expect(query).to be_a base_query.class }

      it { expect(query).not_to be base_query }

      it { expect(query.criteria).to be == expected }

      describe 'with strategy: :unsafe' do
        let(:strategy) { :unsafe }
        let(:filter)   { criteria }

        it 'should not parse the criteria' do
          builder.call(strategy: strategy, where: filter)

          expect(parser).not_to have_received(:call)
        end

        it { expect(query.criteria).to be == expected }
      end

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
            builder.call(strategy: strategy, where: filter)
          end
            .to raise_error Cuprum::Collections::QueryBuilder::ParseError,
              error.message
        end
      end
    end
  end
end
