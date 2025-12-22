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
          **collection_options
        }
      end
    end

    shared_context 'when initialized with primary_key: true' do
      let(:constructor_options) { super().merge(primary_key: true) }
    end

    shared_context 'when initialized with query: value' do
      let(:query) do
        Cuprum::Collections::Basic::Query.new([]).where do |scope|
          {
            'author'       => 'Tamsyn Muir',
            'published_at' => scope.less_than('2020-08-04')
          }
        end
      end
      let(:constructor_options) do
        {
          query:,
          **collection_options
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
            .and_keywords(:entity_class, :name, :qualified_name)
            .and_any_keywords
        end

        describe 'with no query keywords' do
          let(:error_message) do
            'missing keywords :attribute_name, :attribute_value, ' \
              ':attributes, or :query'
          end

          it 'should raise an exception' do
            expect { described_class.new(name:) }
              .to raise_error ArgumentError, error_message
          end
        end

        describe 'with attributes:' do
          let(:keywords) do
            {
              attributes: {
                'title'  => 'Gideon the Ninth',
                'author' => 'Tamsyn Muir'
              },
              name:
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
              name:
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
            Cuprum::Collections::Basic::Query.new([]).where do |scope|
              {
                'author'       => 'Tamsyn Muir',
                'published_at' => scope.less_than('2020-08-04')
              }
            end
          end
          let(:keywords) do
            {
              name:,
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
            'collection'      => error.collection,
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
              'attributes' => attributes,
              'collection' => error.collection,
              'details'    => error.details
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
                'attributes' => expected_attributes,
                'collection' => error.collection,
                'details'    => error.details
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
              'collection' => error.collection,
              'details'    => error.details
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

      describe '#collection' do
        let(:expected) do
          {
            'entity_class'   => 'Book',
            'name'           => 'books',
            'qualified_name' => 'books'
          }
        end

        include_examples 'should define reader', :collection, -> { expected }

        context 'when initialized with collection: a Collection' do
          let(:collection) do
            Cuprum::Collections::Collection.new(
              entity_class:   Spec::BookEntity,
              name:           'books',
              qualified_name: 'spec/book_entities'
            )
          end
          let(:collection_options) { { collection: } }
          let(:expected) do
            {
              'entity_class'   => 'Spec::BookEntity',
              'name'           => 'books',
              'qualified_name' => 'spec/book_entities'
            }
          end

          example_class 'Spec::BookEntity'

          it { expect(error.collection).to be == expected }
        end

        context 'when initialized with collection: a String' do
          let(:collection_options) { { collection: 'books' } }
          let(:expected) do
            { 'name' => 'books' }
          end

          it { expect(error.collection).to be == expected }
        end

        context 'when initialized with collection: a Symbol' do
          let(:collection_options) { { collection: :books } }
          let(:expected) do
            { 'name' => 'books' }
          end

          it { expect(error.collection).to be == expected }
        end

        context 'when initialized with collection_name: value' do
          let(:collection_options) { { collection_name: 'books' } }
          let(:expected) do
            { 'name' => 'books' }
          end

          define_method :tools do
            SleepingKingStudios::Tools::Toolbelt.instance
          end

          before(:example) do
            allow(tools.core_tools).to receive(:deprecate)
          end

          it { expect(error.collection).to be == expected }
        end

        context 'when initialized with entity_class: a Class' do
          let(:entity_class)       { Spec::BookEntity }
          let(:collection_options) { { entity_class: } }
          let(:expected) do
            {
              'entity_class'   => entity_class.name,
              'name'           => 'book_entities',
              'qualified_name' => 'spec/book_entities'
            }
          end

          example_class 'Spec::BookEntity'

          it { expect(error.collection).to be == expected }

          context 'when initialized with name: value' do
            let(:name)               { 'books' }
            let(:collection_options) { super().merge(name:) }
            let(:expected) do
              super().merge({ 'name' => name })
            end

            it { expect(error.collection).to be == expected }
          end

          context 'when initialized with qualified_name: value' do
            let(:qualified_name)     { 'books' }
            let(:collection_options) { super().merge(qualified_name:) }
            let(:expected) do
              super().merge({ 'qualified_name' => qualified_name })
            end

            it { expect(error.collection).to be == expected }
          end
        end

        context 'when initialized with entity_class: a String' do
          let(:entity_class)       { 'Spec::BookEntity' }
          let(:collection_options) { { entity_class: } }
          let(:expected) do
            {
              'entity_class'   => entity_class,
              'name'           => 'book_entities',
              'qualified_name' => 'spec/book_entities'
            }
          end

          it { expect(error.collection).to be == expected }

          context 'when initialized with name: value' do
            let(:name)               { 'books' }
            let(:collection_options) { super().merge(name:) }
            let(:expected) do
              super().merge({ 'name' => name })
            end

            it { expect(error.collection).to be == expected }
          end

          context 'when initialized with qualified_name: value' do
            let(:qualified_name)     { 'books' }
            let(:collection_options) { super().merge(qualified_name:) }
            let(:expected) do
              super().merge({ 'qualified_name' => qualified_name })
            end

            it { expect(error.collection).to be == expected }
          end
        end

        context 'when initialized name: a value' do
          let(:name)               { 'books' }
          let(:collection_options) { { name: } }
          let(:expected) do
            {
              'entity_class'   => 'Book',
              'name'           => name,
              'qualified_name' => name
            }
          end

          it { expect(error.collection).to be == expected }

          context 'when initialized with entity_class: value' do
            let(:entity_class)       { 'Spec::BookEntity' }
            let(:collection_options) { super().merge(entity_class:) }
            let(:expected) do
              super().merge({
                'entity_class'   => entity_class,
                'qualified_name' => 'spec/book_entities'
              })
            end

            it { expect(error.collection).to be == expected }
          end

          context 'when initialized with qualified_name: value' do
            let(:qualified_name)     { 'spec/books' }
            let(:collection_options) { super().merge(qualified_name:) }
            let(:expected) do
              super().merge({
                'entity_class'   => 'Spec::Book',
                'qualified_name' => qualified_name
              })
            end

            it 'should extract the collection details' do
              expect(
                described_class.resolve_collection(name:, qualified_name:)
              )
                .to be == expected
            end
          end
        end

        context 'when initialized with qualified_name: value' do
          let(:qualified_name)     { 'spec/books' }
          let(:collection_options) { { qualified_name: } }
          let(:expected) do
            {
              'entity_class'   => 'Spec::Book',
              'name'           => 'books',
              'qualified_name' => qualified_name
            }
          end

          it { expect(error.collection).to be == expected }

          context 'when initialized with entity_class: value' do
            let(:entity_class)       { 'Spec::BookEntity' }
            let(:collection_options) { super().merge(entity_class:) }
            let(:expected) do
              super().merge({
                'entity_class' => entity_class,
                'name'         => 'book_entities'
              })
            end

            it { expect(error.collection).to be == expected }
          end

          context 'when initialized with name: value' do
            let(:name)               { 'tomes' }
            let(:collection_options) { super().merge(name:) }
            let(:expected) do
              super().merge({ 'name' => name })
            end

            it { expect(error.collection).to be == expected }
          end
        end
      end

      describe '#collection_name' do
        define_method :tools do
          SleepingKingStudios::Tools::Toolbelt.instance
        end

        before(:example) do
          allow(tools.core_tools).to receive(:deprecate)
        end

        include_examples 'should define reader', :collection_name

        it { expect(error.collection_name).to be == name }

        it 'should print a deprecation warning' do
          error.collection_name

          expect(tools.core_tools).to have_received(:deprecate).with(
            '#collection_name is deprecated',
            message: 'Use the #collection method instead.'
          )
        end
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
