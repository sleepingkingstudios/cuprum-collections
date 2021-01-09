# frozen_string_literal: true

require 'cuprum/collections'

module Cuprum::Collections
  # Contract validating the behavior of a QueryBuilder implementation.
  QUERY_BUILDER_CONTRACT = lambda do
    describe '#base_query' do
      include_examples 'should define reader', :base_query, -> { base_query }
    end

    describe '#call' do
      shared_examples 'should append the criteria' do
        it { expect(build_query.criteria).to be == expected }

        context 'when the query has existing criteria' do
          let(:old_criteria) { [['genre', :eq, 'Science Fiction']] }
          let(:expected)     { old_criteria + criteria }
          let(:base_query)   { super().send(:with_criteria, old_criteria) }

          it { expect(build_query.criteria).to be == expected }
        end
      end

      let(:criteria) { [['title', :eq, 'The Naked Sun']] }
      let(:expected) { criteria }

      it 'should define the method' do
        expect(builder).to respond_to(:call).with(0).arguments.and_a_block
      end

      describe 'with a block' do
        let(:block) { -> {} }
        let(:parser) do
          instance_double(
            Cuprum::Collections::Queries::BlockParser,
            call: criteria
          )
        end

        before(:example) do
          allow(Cuprum::Collections::Queries::BlockParser)
            .to receive(:new)
            .and_return(parser)
        end

        def build_query
          builder.call(&block)
        end

        it { expect(builder.call(&block)).to be_a base_query.class }

        it { expect(builder.call(&block)).not_to be base_query }

        it 'should parse the block' do
          allow(parser).to receive(:call) do |&block|
            block.call

            []
          end

          expect { |block| builder.call(&block) }.to yield_control
        end

        include_examples 'should append the criteria'
      end
    end
  end
end
