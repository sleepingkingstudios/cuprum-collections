# frozen_string_literal: true

require 'cuprum/collections/rspec'

module Cuprum::Collections::RSpec
  # Contract validating the behavior of a Filter command implementation.
  FILTER_COMMAND_CONTRACT = lambda do
    describe '#call' do
      shared_examples 'should return the matching items' do
        it { expect(result).to be_a_passing_result }

        it { expect(result.value).to be_a Enumerator }

        it { expect(result.value.to_a).to be == expected_data }
      end

      let(:filter)        { nil }
      let(:limit)         { nil }
      let(:offset)        { nil }
      let(:options)       { {} }
      let(:filtered_data) { data }
      let(:ordered_data)  { filtered_data }
      let(:matching_data) do
        ary = ordered_data
        ary = ary[offset..-1] if offset
        ary = ary[0...limit]  if limit

        ary
      end
      let(:expected_data) do
        defined?(super()) ? super() : matching_data
      end
      let(:result) { command.call(**options, &filter) }

      include_examples 'should validate the keyword',
        :limit,
        type:     Integer,
        optional: true

      include_examples 'should validate the keyword',
        :offset,
        type:     Integer,
        optional: true

      include_examples 'should return the matching items'

      describe 'with an invalid filter block' do
        let(:filter) { -> { nil } }
        let(:error_message) do
          'block must return a Hash'
        end

        it 'should raise an exception' do
          expect { command.call(**options, &filter) }
            .to raise_error ArgumentError, error_message
        end
      end

      describe 'with order: an invalid order' do
        let(:order)   { { title: :random } }
        let(:options) { super().merge(order: order) }
        let(:expected_error) do
          Cuprum::Error.new(
            message: 'order must be a list of attribute names and/or a hash' \
                     ' of attribute names with values :asc or :desc'
          )
        end

        it { expect(result).to be_a_failing_result.with_error(expected_error) }
      end

      describe 'with a filter that does not match any items' do
        let(:filter) do
          # :nocov:
          -> { { author: 'Tammsyn Muir' } }
          # :nocov:
        end
        let(:filtered_data) do
          data.select { |book| book['author'] == 'Tammsyn Muir' }
        end

        include_examples 'should return the matching items'
      end

      wrap_context 'when the collection has many items' do
        include_examples 'should return the matching items'

        describe 'with a filter that does not match any items' do
          let(:filter) do
            -> { { author: 'Tammsyn Muir' } }
          end
          let(:filtered_data) do
            data.select { |book| book['author'] == 'Tammsyn Muir' }
          end

          include_examples 'should return the matching items'
        end

        describe 'with a filter that matches some items' do
          let(:filter) do
            -> { { author: 'J.R.R. Tolkien' } }
          end
          let(:filtered_data) do
            data.select { |book| book['author'] == 'J.R.R. Tolkien' }
          end

          include_examples 'should return the matching items'

          context 'with limit: value' do
            let(:limit)   { 3 }
            let(:options) { super().merge(limit: limit) }

            include_examples 'should return the matching items'
          end

          context 'with offset: value' do
            let(:offset)  { 3 }
            let(:options) { super().merge(offset: offset) }

            include_examples 'should return the matching items'
          end

          context 'with order: value' do
            let(:order)   { :title }
            let(:options) { super().merge(order: order) }
            let(:ordered_data) do
              super().sort_by { |book| book['title'] }
            end

            include_examples 'should return the matching items'
          end

          context 'with multiple options' do
            let(:limit)   { 3 }
            let(:offset)  { 3 }
            let(:order)   { :title }
            let(:options) do
              super().merge(limit: limit, offset: offset, order: order)
            end
            let(:ordered_data) do
              super().sort_by { |book| book['title'] }
            end

            include_examples 'should return the matching items'
          end
        end

        describe 'with a filter that matches all items' do
          let(:filter) do
            -> { { category: 'Science Fiction and Fantasy' } }
          end
          let(:filtered_data) do
            data.select do |book|
              book['category'] == 'Science Fiction and Fantasy'
            end
          end

          include_examples 'should return the matching items'

          context 'with limit: value' do
            let(:limit)   { 3 }
            let(:options) { super().merge(limit: limit) }

            include_examples 'should return the matching items'
          end

          context 'with offset: value' do
            let(:offset)  { 3 }
            let(:options) { super().merge(offset: offset) }

            include_examples 'should return the matching items'
          end

          context 'with order: value' do
            let(:order)   { :title }
            let(:options) { super().merge(order: order) }
            let(:ordered_data) do
              super().sort_by { |book| book['title'] }
            end

            include_examples 'should return the matching items'
          end

          context 'with multiple options' do
            let(:limit)   { 3 }
            let(:offset)  { 3 }
            let(:order)   { :title }
            let(:options) do
              super().merge(limit: limit, offset: offset, order: order)
            end
            let(:ordered_data) do
              super().sort_by { |book| book['title'] }
            end

            include_examples 'should return the matching items'
          end
        end
      end
    end
  end
end
