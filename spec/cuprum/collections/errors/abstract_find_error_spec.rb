# frozen_string_literal: true

require 'cuprum/collections/errors/abstract_find_error'

require 'support/examples/find_error_examples'

RSpec.describe Cuprum::Collections::Errors::AbstractFindError do
  include Spec::Support::Examples::FindErrorExamples

  subject(:error) { described_class.new(**constructor_options) }

  let(:attribute_name)     { 'title' }
  let(:attribute_value)    { 'Gideon the Ninth' }
  let(:name)               { 'books' }
  let(:collection_options) { { name: } }
  let(:constructor_options) do
    {
      attribute_name:,
      attribute_value:,
      **collection_options
    }
  end

  describe '.resolve_collection' do
    it 'should define the class method' do
      expect(described_class)
        .to respond_to(:resolve_collection)
        .with(0).arguments
        .and_any_keywords
    end

    describe 'with no keywords' do
      let(:error_message) do
        "collection, name or entity class can't be blank"
      end

      it 'should raise an exception' do
        expect { described_class.resolve_collection }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with invalid keywords' do
      let(:params) { { invalid: 'parameter' } }
      let(:error_message) do
        "collection, name or entity class can't be blank"
      end

      it 'should raise an exception' do
        expect { described_class.resolve_collection(**params) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with collection: a Collection' do
      let(:collection) do
        Cuprum::Collections::Collection.new(
          entity_class:   Spec::BookEntity,
          name:           'books',
          qualified_name: 'spec/book_entities'
        )
      end
      let(:expected) do
        {
          'entity_class'   => 'Spec::BookEntity',
          'name'           => 'books',
          'qualified_name' => 'spec/book_entities'
        }
      end

      example_class 'Spec::BookEntity'

      it 'should extract the collection details' do
        expect(described_class.resolve_collection(collection:))
          .to be == expected
      end
    end

    describe 'with collection: an empty String' do
      let(:collection) { '' }
      let(:error_message) do
        "collection, name or entity class can't be blank"
      end

      it 'should raise an exception' do
        expect { described_class.resolve_collection(collection:) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with collection: a String' do
      let(:collection) { 'books' }
      let(:expected)   { { 'name' => collection } }

      it 'should extract the collection details' do
        expect(described_class.resolve_collection(collection:))
          .to be == expected
      end
    end

    describe 'with collection: an empty Symbol' do
      let(:collection) { :'' }
      let(:error_message) do
        "collection, name or entity class can't be blank"
      end

      it 'should raise an exception' do
        expect { described_class.resolve_collection(collection:) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with collection: a Symbol' do
      let(:collection) { :books }
      let(:expected)   { { 'name' => collection.to_s } }

      it 'should extract the collection details' do
        expect(described_class.resolve_collection(collection:))
          .to be == expected
      end
    end

    describe 'with collection_name: value' do
      let(:collection_name) { 'books' }
      let(:expected)        { { 'name' => collection_name } }

      define_method :tools do
        SleepingKingStudios::Tools::Toolbelt.instance
      end

      before(:example) do
        allow(tools.core_tools).to receive(:deprecate)
      end

      it 'should extract the collection details' do
        expect(described_class.resolve_collection(collection_name:))
          .to be == expected
      end

      it 'should print a deprecation warning' do
        described_class.resolve_collection(collection_name:)

        expect(tools.core_tools).to have_received(:deprecate).with(
          ':collection_name parameter is deprecated',
          message: 'Use the :name parameter instead.'
        )
      end
    end

    describe 'with entity_class: a Class' do
      let(:entity_class) { Spec::BookEntity }
      let(:expected) do
        {
          'entity_class'   => entity_class.name,
          'name'           => 'book_entities',
          'qualified_name' => 'spec/book_entities'
        }
      end

      example_class 'Spec::BookEntity'

      it 'should extract the collection details' do
        expect(described_class.resolve_collection(entity_class:))
          .to be == expected
      end

      describe 'with name: value' do
        let(:name)     { 'books' }
        let(:expected) { super().merge({ 'name' => name }) }

        it 'should extract the collection details' do
          expect(described_class.resolve_collection(entity_class:, name:))
            .to be == expected
        end
      end

      describe 'with qualified_name: value' do
        let(:qualified_name) { 'books' }
        let(:expected) do
          super().merge({ 'qualified_name' => qualified_name })
        end

        it 'should extract the collection details' do
          expect(
            described_class.resolve_collection(entity_class:, qualified_name:)
          )
            .to be == expected
        end
      end
    end

    describe 'with entity_class: a String' do
      let(:entity_class) { 'Spec::BookEntity' }
      let(:expected) do
        {
          'entity_class'   => entity_class,
          'name'           => 'book_entities',
          'qualified_name' => 'spec/book_entities'
        }
      end

      it 'should extract the collection details' do
        expect(described_class.resolve_collection(entity_class:))
          .to be == expected
      end

      describe 'with name: value' do
        let(:name)     { 'books' }
        let(:expected) { super().merge({ 'name' => name }) }

        it 'should extract the collection details' do
          expect(described_class.resolve_collection(entity_class:, name:))
            .to be == expected
        end
      end

      describe 'with qualified_name: value' do
        let(:qualified_name) { 'books' }
        let(:expected) do
          super().merge({ 'qualified_name' => qualified_name })
        end

        it 'should extract the collection details' do
          expect(
            described_class.resolve_collection(entity_class:, qualified_name:)
          )
            .to be == expected
        end
      end
    end

    describe 'with name: a String' do
      let(:name) { 'books' }
      let(:expected) do
        {
          'entity_class'   => 'Book',
          'name'           => name,
          'qualified_name' => name
        }
      end

      it 'should extract the collection details' do
        expect(described_class.resolve_collection(name:))
          .to be == expected
      end

      describe 'with entity_class: value' do
        let(:entity_class) { 'Spec::BookEntity' }
        let(:expected) do
          super().merge({
            'entity_class'   => entity_class,
            'qualified_name' => 'spec/book_entities'
          })
        end

        it 'should extract the collection details' do
          expect(described_class.resolve_collection(entity_class:, name:))
            .to be == expected
        end
      end

      describe 'with qualified_name: value' do
        let(:qualified_name) { 'spec/books' }
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

    describe 'with name: a Symbol' do
      let(:name) { :books }
      let(:expected) do
        {
          'entity_class'   => 'Book',
          'name'           => name.to_s,
          'qualified_name' => name.to_s
        }
      end

      it 'should extract the collection details' do
        expect(described_class.resolve_collection(name:))
          .to be == expected
      end

      describe 'with entity_class: value' do
        let(:entity_class) { 'Spec::BookEntity' }
        let(:expected) do
          super().merge({
            'entity_class'   => entity_class,
            'qualified_name' => 'spec/book_entities'
          })
        end

        it 'should extract the collection details' do
          expect(described_class.resolve_collection(entity_class:, name:))
            .to be == expected
        end
      end

      describe 'with qualified_name: value' do
        let(:qualified_name) { 'spec/books' }
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

    describe 'with qualified_name: value' do
      let(:qualified_name) { 'spec/books' }
      let(:expected) do
        {
          'entity_class'   => 'Spec::Book',
          'name'           => 'books',
          'qualified_name' => qualified_name
        }
      end

      it 'should extract the collection details' do
        expect(described_class.resolve_collection(qualified_name:))
          .to be == expected
      end

      describe 'with entity_class: value' do
        let(:entity_class) { 'Spec::BookEntity' }
        let(:expected) do
          super().merge({
            'entity_class' => entity_class,
            'name'         => 'book_entities'
          })
        end

        it 'should extract the collection details' do
          expect(
            described_class.resolve_collection(entity_class:, qualified_name:)
          )
            .to be == expected
        end
      end

      describe 'with name: value' do
        let(:name)     { 'tomes' }
        let(:expected) { super().merge({ 'name' => name }) }

        it 'should extract the collection details' do
          expect(described_class.resolve_collection(name:, qualified_name:))
            .to be == expected
        end
      end
    end
  end

  describe '.new' do
    describe 'with collection_name: value' do
      let(:collection_name)    { 'books' }
      let(:collection_options) { { collection_name: } }

      define_method :tools do
        SleepingKingStudios::Tools::Toolbelt.instance
      end

      before(:example) do
        allow(tools.core_tools).to receive(:deprecate)
      end

      it 'should print a deprecation warning' do
        described_class.new(**constructor_options)

        expect(tools.core_tools).to have_received(:deprecate).with(
          ':collection_name parameter is deprecated',
          message: 'Use the :name parameter instead.'
        )
      end
    end
  end

  include_examples 'should implement the FindError methods', 'query failed'
end
