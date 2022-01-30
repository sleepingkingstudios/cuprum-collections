# frozen_string_literal: true

require 'rspec/sleeping_king_studios/concerns/shared_example_group'

require 'support/examples'

module Spec::Support::Examples
  module FindErrorExamples
    extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

    shared_context 'when initialized with attributes: value' do
      let(:attributes) do
        {
          'title'  => 'Gideon the Ninth',
          'author' => 'Tamsyn Muir'
        }
      end
      let(:constructor_options) do
        {
          attributes:      attributes,
          collection_name: collection_name
        }
      end
    end

    shared_context 'when initialized with primary_key: true' do
      let(:constructor_options) { super().merge(primary_key: true) }
    end

    shared_context 'when initialized with query: value' do
      let(:query) do
        Cuprum::Collections::Basic::Query.new([]).where do
          {
            'author'       => 'Tamsyn Muir',
            'published_at' => less_than('2020-08-04')
          }
        end
      end
      let(:constructor_options) do
        {
          collection_name: collection_name,
          query:           query
        }
      end
    end

    shared_context 'when initialized with primary key name and values' do
      let(:primary_key_name)  { 'id' }
      let(:primary_key_value) { 0 }
      let(:constructor_options) do
        {
          collection_name:    collection_name,
          primary_key_name:   primary_key_name,
          primary_key_values: [primary_key_value]
        }
      end

      before(:example) do
        allow(SleepingKingStudios::Tools::CoreTools.instance)
          .to receive(:deprecate)
      end
    end

    shared_examples 'should implement the FindError methods' \
    do |message_fragment|
      describe '.new' do
        shared_examples 'should validate the keywords' do
          describe 'with one extra keyword' do
            let(:keywords)      { super().merge(one: 1) }
            let(:error_message) { 'unknown keyword :one' }

            it 'should raise an exception' do
              expect { described_class.new(**keywords) }
                .to raise_error ArgumentError, error_message
            end
          end

          describe 'with multiple extra keywords' do
            let(:keywords)      { super().merge(one: 1, two: 2, three: 3) }
            let(:error_message) { 'unknown keywords :one, :two, :three' }

            it 'should raise an exception' do
              expect { described_class.new(**keywords) }
                .to raise_error ArgumentError, error_message
            end
          end
        end

        it 'should define the constructor' do
          expect(described_class)
            .to be_constructible
            .with(0).arguments
            .and_keywords(:collection_name)
            .and_any_keywords
        end

        describe 'with no query keywords' do
          let(:error_message) do
            'missing keywords :attribute_name, :attribute_value or ' \
              ':attributes or :query'
          end

          it 'should raise an exception' do
            expect { described_class.new(collection_name: collection_name) }
              .to raise_error ArgumentError, error_message
          end
        end

        describe 'with attributes:' do
          let(:keywords) do
            {
              attributes:      {
                'title'  => 'Gideon the Ninth',
                'author' => 'Tamsyn Muir'
              },
              collection_name: collection_name
            }
          end

          include_examples 'should validate the keywords'

          describe 'with attribute_name: value' do
            let(:keywords)      { super().merge(attribute_name: 'name') }
            let(:error_message) { 'ambiguous keyword :attribute_name' }

            it 'should raise an exception' do
              expect { described_class.new(**keywords) }
                .to raise_error ArgumentError, error_message
            end
          end

          describe 'with attribute_value: value' do
            let(:keywords)      { super().merge(attribute_value: 'value') }
            let(:error_message) { 'ambiguous keyword :attribute_value' }

            it 'should raise an exception' do
              expect { described_class.new(**keywords) }
                .to raise_error ArgumentError, error_message
            end
          end

          describe 'with query: value' do
            let(:keywords)      { super().merge(query: Object.new.freeze) }
            let(:error_message) { 'ambiguous keyword :query' }

            it 'should raise an exception' do
              expect { described_class.new(**keywords) }
                .to raise_error ArgumentError, error_message
            end
          end

          describe 'with multiple ambiguous keywords' do
            let(:keywords) do
              super().merge(attribute_name: 'name', query: Object.new.freeze)
            end
            let(:error_message) { 'ambiguous keywords :attribute_name, :query' }

            it 'should raise an exception' do
              expect { described_class.new(**keywords) }
                .to raise_error ArgumentError, error_message
            end
          end
        end

        describe 'with attribute_name:, attribute_value:' do
          let(:keywords) do
            {
              attribute_name:  'name',
              attribute_value: 'Alan Bradley',
              collection_name: collection_name
            }
          end

          include_examples 'should validate the keywords'

          describe 'with attributes: value' do
            let(:keywords)      { super().merge(attributes: {}) }
            let(:error_message) { 'ambiguous keyword :attributes' }

            it 'should raise an exception' do
              expect { described_class.new(**keywords) }
                .to raise_error ArgumentError, error_message
            end
          end

          describe 'with query: value' do
            let(:keywords)      { super().merge(query: Object.new.freeze) }
            let(:error_message) { 'ambiguous keyword :query' }

            it 'should raise an exception' do
              expect { described_class.new(**keywords) }
                .to raise_error ArgumentError, error_message
            end
          end

          describe 'with multiple ambiguous keywords' do
            let(:keywords) do
              super().merge(attributes: {}, query: Object.new.freeze)
            end
            let(:error_message) { 'ambiguous keywords :attributes, :query' }

            it 'should raise an exception' do
              expect { described_class.new(**keywords) }
                .to raise_error ArgumentError, error_message
            end
          end
        end

        describe 'with query:' do
          let(:query) do
            Cuprum::Collections::Basic::Query.new([]).where do
              {
                'author'       => 'Tamsyn Muir',
                'published_at' => less_than('2020-08-04')
              }
            end
          end
          let(:keywords) do
            {
              collection_name: collection_name,
              query:           query
            }
          end

          include_examples 'should validate the keywords'

          describe 'with attribute_name: value' do
            let(:keywords)      { super().merge(attribute_name: 'name') }
            let(:error_message) { 'ambiguous keyword :attribute_name' }

            it 'should raise an exception' do
              expect { described_class.new(**keywords) }
                .to raise_error ArgumentError, error_message
            end
          end

          describe 'with attribute_value: value' do
            let(:keywords)      { super().merge(attribute_value: 'value') }
            let(:error_message) { 'ambiguous keyword :attribute_value' }

            it 'should raise an exception' do
              expect { described_class.new(**keywords) }
                .to raise_error ArgumentError, error_message
            end
          end
        end

        describe 'with primary_key_name:, primary_key_values:' do
          let(:keywords) do
            {
              collection_name:    collection_name,
              primary_key_name:   'name',
              primary_key_values: ['Alan Bradley']
            }
          end
          let(:error_message) do
            'deprecated mode does not support empty or multiple attribute' \
              ' values'
          end

          before(:example) do
            allow(SleepingKingStudios::Tools::CoreTools.instance)
              .to receive(:deprecate)
          end

          it 'should print a deprecation warning' do # rubocop:disable RSpec/ExampleLength
            described_class.new(**keywords)

            expect(SleepingKingStudios::Tools::CoreTools.instance)
              .to have_received(:deprecate)
              .with(
                'NotFound.new(primary_key_name:, primary_key_values:)',
                message: 'use NotFound.new(attribute_name:, attribute_value:)'
              )
          end

          context 'when the values Array is empty' do
            let(:keywords) { super().merge(primary_key_values: []) }

            it 'should raise an exception' do
              expect { described_class.new(**keywords) }
                .to raise_error ArgumentError, error_message
            end
          end

          context 'when the values Array has multiple items' do
            let(:keywords) do
              super().merge(primary_key_values: ['Alan Bradley', 'Kevin Flynn'])
            end

            it 'should raise an exception' do
              expect { described_class.new(**keywords) }
                .to raise_error ArgumentError, error_message
            end
          end
        end
      end

      describe '#as_json' do
        let(:expected_data) do
          {
            'attribute_name'  => attribute_name,
            'attribute_value' => attribute_value,
            'collection_name' => collection_name,
            'details'         => error.details,
            'primary_key'     => false
          }
        end
        let(:expected) do
          {
            'data'    => expected_data,
            'message' => error.message,
            'type'    => error.type
          }
        end

        include_examples 'should define reader',
          :as_json,
          -> { be == expected }

        wrap_context 'when initialized with attributes: value' do
          let(:expected_data) do
            {
              'attributes'      => attributes,
              'collection_name' => collection_name,
              'details'         => error.details
            }
          end

          it { expect(error.as_json).to be == expected }
        end

        wrap_context 'when initialized with query: value' do
          let(:expected_data) do
            {
              'collection_name' => collection_name,
              'details'         => error.details
            }
          end

          it { expect(error.as_json).to be == expected }
        end

        wrap_context 'when initialized with primary_key: true' do
          let(:expected_data) do
            super().merge('primary_key' => true)
          end

          it { expect(error.as_json).to be == expected }
        end

        wrap_context 'when initialized with primary key name and values' do
          let(:expected_data) do
            {
              'attribute_name'  => primary_key_name,
              'collection_name' => collection_name,
              'attribute_value' => primary_key_value,
              'details'         => error.details,
              'primary_key'     => true
            }
          end

          it { expect(error.as_json).to be == expected }
        end
      end

      describe '#attribute_name' do
        include_examples 'should define reader',
          :attribute_name,
          -> { attribute_name }

        # rubocop:disable RSpec/RepeatedExampleGroupBody
        wrap_context 'when initialized with attributes: value' do
          it { expect(error.attribute_name).to be nil }
        end

        wrap_context 'when initialized with query: value' do
          it { expect(error.attribute_name).to be nil }
        end
        # rubocop:enable RSpec/RepeatedExampleGroupBody

        wrap_context 'when initialized with primary key name and values' do
          it { expect(error.attribute_name).to be == primary_key_name }
        end
      end

      describe '#attribute_value' do
        include_examples 'should define reader',
          :attribute_value,
          -> { attribute_value }

        # rubocop:disable RSpec/RepeatedExampleGroupBody
        wrap_context 'when initialized with attributes: value' do
          it { expect(error.attribute_value).to be nil }
        end

        wrap_context 'when initialized with query: value' do
          it { expect(error.attribute_value).to be nil }
        end
        # rubocop:enable RSpec/RepeatedExampleGroupBody

        wrap_context 'when initialized with primary key name and values' do
          it { expect(error.attribute_value).to be == primary_key_value }
        end
      end

      describe '#attributes' do
        include_examples 'should define reader', :attributes, nil

        wrap_context 'when initialized with attributes: value' do
          it { expect(error.attributes).to be == attributes }
        end

        # rubocop:disable RSpec/RepeatedExampleGroupBody
        wrap_context 'when initialized with query: value' do
          it { expect(error.attributes).to be nil }
        end

        wrap_context 'when initialized with primary key name and values' do
          it { expect(error.attributes).to be nil }
        end
        # rubocop:enable RSpec/RepeatedExampleGroupBody
      end

      describe '#collection_name' do
        include_examples 'should define reader',
          :collection_name,
          -> { collection_name }
      end

      describe '#details' do
        let(:expected) { [[attribute_name, :equal, attribute_value]] }

        include_examples 'should define reader', :details, -> { expected }

        wrap_context 'when initialized with attributes: value' do
          let(:expected) do
            attributes.map do |attribute_name, attribute_value|
              [attribute_name, :equal, attribute_value]
            end
          end

          it { expect(error.details).to be == expected }
        end

        wrap_context 'when initialized with query: value' do
          let(:expected) { query.criteria }

          it { expect(error.details).to be == expected }
        end

        wrap_context 'when initialized with primary key name and values' do
          let(:expected) { [[primary_key_name, :equal, primary_key_value]] }

          it { expect(error.details).to be == expected }
        end
      end

      describe '#message' do
        include_examples 'should define reader', :message

        wrap_context 'when initialized with attributes: value' do
          let(:expected) do
            "Book #{message_fragment} with attributes #{attributes.inspect}"
          end

          it { expect(error.message).to be == expected }
        end

        wrap_context 'when initialized with query: value' do
          let(:expected) do
            "Book #{message_fragment} matching the query"
          end

          it { expect(error.message).to be == expected }
        end

        wrap_context 'when initialized with primary key name and values' do
          let(:expected) do
            "Book #{message_fragment} with #{primary_key_name.inspect}" \
              " #{primary_key_value.inspect} (primary key)"
          end

          it { expect(error.message).to be == expected }
        end
      end

      describe '#primary_key?' do
        include_examples 'should define predicate', :primary_key?, false

        # rubocop:disable RSpec/RepeatedExampleGroupBody
        wrap_context 'when initialized with attributes: value' do
          it { expect(error.primary_key?).to be false }
        end

        wrap_context 'when initialized with query: value' do
          it { expect(error.primary_key?).to be false }
        end

        wrap_context 'when initialized with primary_key: true' do
          it { expect(error.primary_key?).to be true }
        end

        wrap_context 'when initialized with primary key name and values' do
          it { expect(error.primary_key?).to be true }
        end
        # rubocop:enable RSpec/RepeatedExampleGroupBody
      end

      describe '#query' do
        include_examples 'should define reader', :query, nil

        # rubocop:disable RSpec/RepeatedExampleGroupBody
        wrap_context 'when initialized with attributes: value' do
          it { expect(error.query).to be nil }
        end

        wrap_context 'when initialized with query: value' do
          it { expect(error.query).to be query }
        end

        wrap_context 'when initialized with primary key name and values' do
          it { expect(error.query).to be nil }
        end
        # rubocop:enable RSpec/RepeatedExampleGroupBody
      end
    end
  end
end
