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
          attributes:,
          collection_name:
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
          collection_name:,
          query:
        }
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
            expect { described_class.new(collection_name:) }
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
              collection_name:
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
              collection_name:
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
              collection_name:,
              query:
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

          describe 'with attributes: a Hash with Symbol keys' do
            let(:attributes) do
              tools.hash_tools.convert_keys_to_symbols(super())
            end
            let(:expected_attributes) do
              tools.hash_tools.convert_keys_to_strings(attributes)
            end
            let(:expected_data) do
              {
                'attributes'      => expected_attributes,
                'collection_name' => collection_name,
                'details'         => error.details
              }
            end

            def tools
              SleepingKingStudios::Tools::Toolbelt.instance
            end

            it { expect(error.as_json).to be == expected }
          end
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
      end

      describe '#attribute_value' do
        include_examples 'should define reader',
          :attribute_value,
          -> { attribute_value }

        # rubocop:disable RSpec/RepeatedExampleGroupBody
        context 'when initialized with attribute_value: nil' do
          let(:attribute_value) { nil }

          it { expect(error.attribute_value).to be nil }
        end

        wrap_context 'when initialized with attributes: value' do
          it { expect(error.attribute_value).to be nil }
        end

        wrap_context 'when initialized with query: value' do
          it { expect(error.attribute_value).to be nil }
        end
        # rubocop:enable RSpec/RepeatedExampleGroupBody
      end

      describe '#attributes' do
        include_examples 'should define reader', :attributes, nil

        wrap_context 'when initialized with attributes: value' do
          it { expect(error.attributes).to be == attributes }
        end

        wrap_context 'when initialized with query: value' do
          it { expect(error.attributes).to be nil }
        end
      end

      describe '#collection_name' do
        include_examples 'should define reader',
          :collection_name,
          -> { collection_name }
      end

      describe '#details' do
        let(:expected) do
          criteria = [[attribute_name, :equal, attribute_value]]

          {
            'criteria' => criteria,
            'type'     => :criteria
          }
        end

        include_examples 'should define reader', :details, -> { expected }

        wrap_context 'when initialized with attributes: value' do
          let(:expected) do
            criteria = attributes.map do |attribute_name, attribute_value|
              [attribute_name, :equal, attribute_value]
            end

            {
              'criteria' => criteria,
              'type'     => :criteria
            }
          end

          it { expect(error.details).to be == expected }
        end

        wrap_context 'when initialized with query: value' do
          let(:expected) { query.scope }

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
        # rubocop:enable RSpec/RepeatedExampleGroupBody
      end

      describe '#scope' do
        include_examples 'should define reader', :scope, nil

        wrap_context 'when initialized with attributes: value' do
          it { expect(error.scope).to be nil }
        end

        wrap_context 'when initialized with query: value' do
          it { expect(error.scope).to be query.scope }
        end
      end
    end
  end
end
