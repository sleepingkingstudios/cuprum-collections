# frozen_string_literal: true

require 'cuprum/collections/relations/parameters'
require 'cuprum/collections/rspec/deferred/relation_examples'

require 'support/book'
require 'support/grimoire'
require 'support/scoped_book'

RSpec.describe Cuprum::Collections::Relations::Parameters do
  include Cuprum::Collections::RSpec::Deferred::RelationExamples

  subject(:relation) { described_class.new }

  let(:concern)         { Cuprum::Collections::Relations::Parameters } # rubocop:disable RSpec/DescribedClass
  let(:described_class) { Spec::ExampleRelation }

  example_class 'Spec::ExampleRelation' do |klass|
    klass.include Cuprum::Collections::Relations::Parameters # rubocop:disable RSpec/DescribedClass
  end

  describe '.resolve_parameters' do
    let(:parameters) { {} }

    def call_method(**parameters)
      concern.resolve_parameters(parameters)
    end

    it 'should define the class method' do
      expect(concern)
        .to respond_to(:resolve_parameters)
        .with(1).argument
    end

    include_deferred 'should validate the Relation parameters'

    describe 'with entity_class: a Class' do
      let(:entity_class) { Book }
      let(:parameters)   { { entity_class: } }
      let(:expected) do
        {
          entity_class:   Book,
          name:           'books',
          plural_name:    'books',
          qualified_name: 'books',
          singular_name:  'book'
        }
      end

      it { expect(call_method(**parameters)).to be == expected }

      describe 'with name: a String' do
        let(:name)       { 'grimoires' }
        let(:parameters) { super().merge(name:) }
        let(:expected) do
          super().merge(
            name:,
            plural_name:   'grimoires',
            singular_name: 'grimoire'
          )
        end

        it { expect(call_method(**parameters)).to be == expected }
      end

      describe 'with name: a Symbol' do
        let(:name)       { :grimoires }
        let(:parameters) { super().merge(name:) }
        let(:expected) do
          super().merge(
            name:          name.to_s,
            plural_name:   'grimoires',
            singular_name: 'grimoire'
          )
        end

        it { expect(call_method(**parameters)).to be == expected }
      end

      describe 'with plural_name: a String' do
        let(:plural_name) { 'grimoires' }
        let(:parameters)  { super().merge(plural_name:) }
        let(:expected)    { super().merge(plural_name:) }

        it { expect(call_method(**parameters)).to be == expected }
      end

      describe 'with plural_name: a Symbol' do
        let(:plural_name) { :grimoire }
        let(:parameters)  { super().merge(plural_name:) }
        let(:expected)    { super().merge(plural_name: plural_name.to_s) }

        it { expect(call_method(**parameters)).to be == expected }
      end

      describe 'with qualified_name: a String' do
        let(:qualified_name) { 'grimoires' }
        let(:parameters)     { super().merge(qualified_name:) }
        let(:expected)       { super().merge(qualified_name:) }

        it { expect(call_method(**parameters)).to be == expected }
      end

      describe 'with qualified_name: a Symbol' do
        let(:qualified_name) { 'grimoires' }
        let(:parameters)     { super().merge(qualified_name:) }
        let(:expected) do
          super().merge(qualified_name: qualified_name.to_s)
        end

        it { expect(call_method(**parameters)).to be == expected }
      end

      describe 'with singular_name: a String' do
        let(:singular_name) { 'grimoire' }
        let(:parameters)  { super().merge(singular_name:) }
        let(:expected)    { super().merge(singular_name:) }

        it { expect(call_method(**parameters)).to be == expected }
      end

      describe 'with singular_name: a Symbol' do
        let(:singular_name) { :grimoire }
        let(:parameters)  { super().merge(singular_name:) }
        let(:expected)    { super().merge(singular_name: singular_name.to_s) }

        it { expect(call_method(**parameters)).to be == expected }
      end
    end

    describe 'with entity_class: a scoped Class' do
      let(:entity_class) { Spec::ScopedBook }
      let(:parameters)   { { entity_class: } }
      let(:expected) do
        {
          entity_class:   Spec::ScopedBook,
          name:           'scoped_books',
          plural_name:    'scoped_books',
          qualified_name: 'spec/scoped_books',
          singular_name:  'scoped_book'
        }
      end

      it { expect(call_method(**parameters)).to be == expected }

      describe 'with name: a String' do
        let(:name)       { 'grimoires' }
        let(:parameters) { super().merge(name:) }
        let(:expected) do
          super().merge(
            name:,
            plural_name:   'grimoires',
            singular_name: 'grimoire'
          )
        end

        it { expect(call_method(**parameters)).to be == expected }
      end

      describe 'with name: a Symbol' do
        let(:name)       { :grimoires }
        let(:parameters) { super().merge(name:) }
        let(:expected) do
          super().merge(
            name:          name.to_s,
            plural_name:   'grimoires',
            singular_name: 'grimoire'
          )
        end

        it { expect(call_method(**parameters)).to be == expected }
      end

      describe 'with plural_name: a String' do
        let(:plural_name) { 'grimoires' }
        let(:parameters)  { super().merge(plural_name:) }
        let(:expected)    { super().merge(plural_name:) }

        it { expect(call_method(**parameters)).to be == expected }
      end

      describe 'with plural_name: a Symbol' do
        let(:plural_name) { :grimoire }
        let(:parameters)  { super().merge(plural_name:) }
        let(:expected)    { super().merge(plural_name: plural_name.to_s) }

        it { expect(call_method(**parameters)).to be == expected }
      end

      describe 'with qualified_name: a String' do
        let(:qualified_name) { 'grimoires' }
        let(:parameters)     { super().merge(qualified_name:) }
        let(:expected)       { super().merge(qualified_name:) }

        it { expect(call_method(**parameters)).to be == expected }
      end

      describe 'with qualified_name: a Symbol' do
        let(:qualified_name) { 'grimoires' }
        let(:parameters)     { super().merge(qualified_name:) }
        let(:expected) do
          super().merge(qualified_name: qualified_name.to_s)
        end

        it { expect(call_method(**parameters)).to be == expected }
      end

      describe 'with singular_name: a String' do
        let(:singular_name) { 'grimoire' }
        let(:parameters)  { super().merge(singular_name:) }
        let(:expected)    { super().merge(singular_name:) }

        it { expect(call_method(**parameters)).to be == expected }
      end

      describe 'with singular_name: a Symbol' do
        let(:singular_name) { :grimoire }
        let(:parameters)  { super().merge(singular_name:) }
        let(:expected)    { super().merge(singular_name: singular_name.to_s) }

        it { expect(call_method(**parameters)).to be == expected }
      end
    end

    describe 'with entity_class: a String' do
      let(:entity_class) { 'Book' }
      let(:parameters)   { { entity_class: } }
      let(:expected) do
        {
          entity_class:   'Book',
          name:           'books',
          plural_name:    'books',
          qualified_name: 'books',
          singular_name:  'book'
        }
      end

      it { expect(call_method(**parameters)).to be == expected }

      describe 'with name: a String' do
        let(:name)       { 'grimoires' }
        let(:parameters) { super().merge(name:) }
        let(:expected) do
          super().merge(
            name:,
            plural_name:   'grimoires',
            singular_name: 'grimoire'
          )
        end

        it { expect(call_method(**parameters)).to be == expected }
      end

      describe 'with name: a Symbol' do
        let(:name)       { :grimoires }
        let(:parameters) { super().merge(name:) }
        let(:expected) do
          super().merge(
            name:          name.to_s,
            plural_name:   'grimoires',
            singular_name: 'grimoire'
          )
        end

        it { expect(call_method(**parameters)).to be == expected }
      end

      describe 'with plural_name: a String' do
        let(:plural_name) { 'grimoires' }
        let(:parameters)  { super().merge(plural_name:) }
        let(:expected)    { super().merge(plural_name:) }

        it { expect(call_method(**parameters)).to be == expected }
      end

      describe 'with plural_name: a Symbol' do
        let(:plural_name) { :grimoires }
        let(:parameters)  { super().merge(plural_name:) }
        let(:expected)    { super().merge(plural_name: plural_name.to_s) }

        it { expect(call_method(**parameters)).to be == expected }
      end

      describe 'with qualified_name: a String' do
        let(:qualified_name) { 'grimoires' }
        let(:parameters)     { super().merge(qualified_name:) }
        let(:expected)       { super().merge(qualified_name:) }

        it { expect(call_method(**parameters)).to be == expected }
      end

      describe 'with qualified_name: a Symbol' do
        let(:qualified_name) { 'grimoires' }
        let(:parameters)     { super().merge(qualified_name:) }
        let(:expected) do
          super().merge(qualified_name: qualified_name.to_s)
        end

        it { expect(call_method(**parameters)).to be == expected }
      end

      describe 'with singular_name: a String' do
        let(:singular_name) { 'grimoire' }
        let(:parameters)  { super().merge(singular_name:) }
        let(:expected)    { super().merge(singular_name:) }

        it { expect(call_method(**parameters)).to be == expected }
      end

      describe 'with singular_name: a Symbol' do
        let(:singular_name) { :grimoire }
        let(:parameters)  { super().merge(singular_name:) }
        let(:expected)    { super().merge(singular_name: singular_name.to_s) }

        it { expect(call_method(**parameters)).to be == expected }
      end
    end

    describe 'with entity_class: a scoped String' do
      let(:entity_class) { 'Spec::ScopedBook' }
      let(:parameters)   { { entity_class: } }
      let(:expected) do
        {
          entity_class:   'Spec::ScopedBook',
          name:           'scoped_books',
          plural_name:    'scoped_books',
          qualified_name: 'spec/scoped_books',
          singular_name:  'scoped_book'
        }
      end

      it { expect(call_method(**parameters)).to be == expected }

      describe 'with name: a String' do
        let(:name)       { 'grimoires' }
        let(:parameters) { super().merge(name:) }
        let(:expected) do
          super().merge(
            name:,
            plural_name:   'grimoires',
            singular_name: 'grimoire'
          )
        end

        it { expect(call_method(**parameters)).to be == expected }
      end

      describe 'with name: a Symbol' do
        let(:name)       { :grimoires }
        let(:parameters) { super().merge(name:) }
        let(:expected) do
          super().merge(
            name:          name.to_s,
            plural_name:   'grimoires',
            singular_name: 'grimoire'
          )
        end

        it { expect(call_method(**parameters)).to be == expected }
      end

      describe 'with plural_name: a String' do
        let(:plural_name) { 'grimoires' }
        let(:parameters)  { super().merge(plural_name:) }
        let(:expected)    { super().merge(plural_name:) }

        it { expect(call_method(**parameters)).to be == expected }
      end

      describe 'with plural_name: a Symbol' do
        let(:plural_name) { :grimoires }
        let(:parameters)  { super().merge(plural_name:) }
        let(:expected)    { super().merge(plural_name: plural_name.to_s) }

        it { expect(call_method(**parameters)).to be == expected }
      end

      describe 'with qualified_name: a String' do
        let(:qualified_name) { 'grimoires' }
        let(:parameters)     { super().merge(qualified_name:) }
        let(:expected)       { super().merge(qualified_name:) }

        it { expect(call_method(**parameters)).to be == expected }
      end

      describe 'with qualified_name: a Symbol' do
        let(:qualified_name) { 'grimoires' }
        let(:parameters)     { super().merge(qualified_name:) }
        let(:expected) do
          super().merge(qualified_name: qualified_name.to_s)
        end

        it { expect(call_method(**parameters)).to be == expected }
      end

      describe 'with singular_name: a String' do
        let(:singular_name) { 'grimoire' }
        let(:parameters)  { super().merge(singular_name:) }
        let(:expected)    { super().merge(singular_name:) }

        it { expect(call_method(**parameters)).to be == expected }
      end

      describe 'with singular_name: a Symbol' do
        let(:singular_name) { :grimoire }
        let(:parameters)  { super().merge(singular_name:) }
        let(:expected)    { super().merge(singular_name: singular_name.to_s) }

        it { expect(call_method(**parameters)).to be == expected }
      end
    end

    describe 'with name: a String' do
      let(:name)         { 'books' }
      let(:parameters)   { { name: } }
      let(:expected) do
        {
          entity_class:   'Book',
          name:           'books',
          plural_name:    'books',
          qualified_name: 'books',
          singular_name:  'book'
        }
      end

      it { expect(call_method(**parameters)).to be == expected }

      describe 'with entity_class: a Class' do
        let(:entity_class) { Grimoire }
        let(:parameters)   { super().merge(entity_class:) }
        let(:expected) do
          super().merge(
            entity_class:,
            qualified_name: 'grimoires'
          )
        end

        it { expect(call_method(**parameters)).to be == expected }
      end

      describe 'with entity_class: a scoped Class' do
        let(:entity_class) { Spec::ScopedBook }
        let(:parameters)   { super().merge(entity_class:) }
        let(:expected) do
          super().merge(
            entity_class:,
            qualified_name: 'spec/scoped_books'
          )
        end

        it { expect(call_method(**parameters)).to be == expected }
      end

      describe 'with entity_class: a String' do
        let(:entity_class) { 'Grimoire' }
        let(:parameters)   { super().merge(entity_class:) }
        let(:expected) do
          super().merge(
            entity_class:,
            qualified_name: 'grimoires'
          )
        end

        it { expect(call_method(**parameters)).to be == expected }
      end

      describe 'with entity_class: a scoped String' do
        let(:entity_class) { 'Spec::ScopedBook' }
        let(:parameters)   { super().merge(entity_class:) }
        let(:expected) do
          super().merge(
            entity_class:,
            qualified_name: 'spec/scoped_books'
          )
        end

        it { expect(call_method(**parameters)).to be == expected }
      end

      describe 'with plural_name: a String' do
        let(:plural_name) { 'grimoires' }
        let(:parameters)  { super().merge(plural_name:) }
        let(:expected)    { super().merge(plural_name:) }

        it { expect(call_method(**parameters)).to be == expected }
      end

      describe 'with plural_name: a Symbol' do
        let(:plural_name) { :grimoires }
        let(:parameters)  { super().merge(plural_name:) }
        let(:expected)    { super().merge(plural_name: plural_name.to_s) }

        it { expect(call_method(**parameters)).to be == expected }
      end

      describe 'with qualified_name: a String' do
        let(:qualified_name) { 'grimoires' }
        let(:parameters)     { super().merge(qualified_name:) }
        let(:expected) do
          super().merge(
            entity_class:   'Grimoire',
            qualified_name:
          )
        end

        it { expect(call_method(**parameters)).to be == expected }
      end

      describe 'with qualified_name: a Symbol' do
        let(:qualified_name) { :grimoires }
        let(:parameters)     { super().merge(qualified_name:) }
        let(:expected) do
          super().merge(
            entity_class:   'Grimoire',
            qualified_name: qualified_name.to_s
          )
        end

        it { expect(call_method(**parameters)).to be == expected }
      end

      describe 'with singular_name: a String' do
        let(:singular_name) { 'grimoire' }
        let(:parameters)  { super().merge(singular_name:) }
        let(:expected)    { super().merge(singular_name:) }

        it { expect(call_method(**parameters)).to be == expected }
      end

      describe 'with singular_name: a Symbol' do
        let(:singular_name) { :grimoire }
        let(:parameters)  { super().merge(singular_name:) }
        let(:expected)    { super().merge(singular_name: singular_name.to_s) }

        it { expect(call_method(**parameters)).to be == expected }
      end
    end

    describe 'with name: a Symbol' do
      let(:name)         { :books }
      let(:parameters)   { { name: } }
      let(:expected) do
        {
          entity_class:   'Book',
          name:           'books',
          plural_name:    'books',
          qualified_name: 'books',
          singular_name:  'book'
        }
      end

      it { expect(call_method(**parameters)).to be == expected }

      describe 'with entity_class: a Class' do
        let(:entity_class) { Grimoire }
        let(:parameters)   { super().merge(entity_class:) }
        let(:expected) do
          super().merge(
            entity_class:,
            qualified_name: 'grimoires'
          )
        end

        it { expect(call_method(**parameters)).to be == expected }
      end

      describe 'with entity_class: a scoped Class' do
        let(:entity_class) { Spec::ScopedBook }
        let(:parameters)   { super().merge(entity_class:) }
        let(:expected) do
          super().merge(
            entity_class:,
            qualified_name: 'spec/scoped_books'
          )
        end

        it { expect(call_method(**parameters)).to be == expected }
      end

      describe 'with entity_class: a String' do
        let(:entity_class) { 'Grimoire' }
        let(:parameters)   { super().merge(entity_class:) }
        let(:expected) do
          super().merge(
            entity_class:,
            qualified_name: 'grimoires'
          )
        end

        it { expect(call_method(**parameters)).to be == expected }
      end

      describe 'with entity_class: a scoped String' do
        let(:entity_class) { 'Spec::ScopedBook' }
        let(:parameters)   { super().merge(entity_class:) }
        let(:expected) do
          super().merge(
            entity_class:,
            qualified_name: 'spec/scoped_books'
          )
        end

        it { expect(call_method(**parameters)).to be == expected }
      end

      describe 'with plural_name: a String' do
        let(:plural_name) { 'grimoires' }
        let(:parameters)  { super().merge(plural_name:) }
        let(:expected)    { super().merge(plural_name:) }

        it { expect(call_method(**parameters)).to be == expected }
      end

      describe 'with plural_name: a Symbol' do
        let(:plural_name) { :grimoires }
        let(:parameters)  { super().merge(plural_name:) }
        let(:expected)    { super().merge(plural_name: plural_name.to_s) }

        it { expect(call_method(**parameters)).to be == expected }
      end

      describe 'with qualified_name: a String' do
        let(:qualified_name) { 'grimoires' }
        let(:parameters)     { super().merge(qualified_name:) }
        let(:expected) do
          super().merge(
            entity_class:   'Grimoire',
            qualified_name:
          )
        end

        it { expect(call_method(**parameters)).to be == expected }
      end

      describe 'with qualified_name: a Symbol' do
        let(:qualified_name) { :grimoires }
        let(:parameters)     { super().merge(qualified_name:) }
        let(:expected) do
          super().merge(
            entity_class:   'Grimoire',
            qualified_name: qualified_name.to_s
          )
        end

        it { expect(call_method(**parameters)).to be == expected }
      end

      describe 'with singular_name: a String' do
        let(:singular_name) { 'grimoire' }
        let(:parameters)  { super().merge(singular_name:) }
        let(:expected)    { super().merge(singular_name:) }

        it { expect(call_method(**parameters)).to be == expected }
      end

      describe 'with singular_name: a Symbol' do
        let(:singular_name) { :grimoire }
        let(:parameters)  { super().merge(singular_name:) }
        let(:expected)    { super().merge(singular_name: singular_name.to_s) }

        it { expect(call_method(**parameters)).to be == expected }
      end
    end

    describe 'with name: a singular String' do
      let(:name)         { 'book' }
      let(:parameters)   { { name: } }
      let(:expected) do
        {
          entity_class:   'Book',
          name:           'book',
          plural_name:    'books',
          qualified_name: 'books',
          singular_name:  'book'
        }
      end

      it { expect(call_method(**parameters)).to be == expected }

      describe 'with entity_class: a Class' do
        let(:entity_class) { Grimoire }
        let(:parameters)   { super().merge(entity_class:) }
        let(:expected) do
          super().merge(
            entity_class:,
            qualified_name: 'grimoires'
          )
        end

        it { expect(call_method(**parameters)).to be == expected }
      end

      describe 'with entity_class: a scoped Class' do
        let(:entity_class) { Spec::ScopedBook }
        let(:parameters)   { super().merge(entity_class:) }
        let(:expected) do
          super().merge(
            entity_class:,
            qualified_name: 'spec/scoped_books'
          )
        end

        it { expect(call_method(**parameters)).to be == expected }
      end

      describe 'with entity_class: a String' do
        let(:entity_class) { 'Grimoire' }
        let(:parameters)   { super().merge(entity_class:) }
        let(:expected) do
          super().merge(
            entity_class:,
            qualified_name: 'grimoires'
          )
        end

        it { expect(call_method(**parameters)).to be == expected }
      end

      describe 'with entity_class: a scoped String' do
        let(:entity_class) { 'Spec::ScopedBook' }
        let(:parameters)   { super().merge(entity_class:) }
        let(:expected) do
          super().merge(
            entity_class:,
            qualified_name: 'spec/scoped_books'
          )
        end

        it { expect(call_method(**parameters)).to be == expected }
      end

      describe 'with plural_name: a String' do
        let(:plural_name) { 'grimoires' }
        let(:parameters)  { super().merge(plural_name:) }
        let(:expected)    { super().merge(plural_name:) }

        it { expect(call_method(**parameters)).to be == expected }
      end

      describe 'with plural_name: a Symbol' do
        let(:plural_name) { :grimoires }
        let(:parameters)  { super().merge(plural_name:) }
        let(:expected)    { super().merge(plural_name: plural_name.to_s) }

        it { expect(call_method(**parameters)).to be == expected }
      end

      describe 'with qualified_name: a String' do
        let(:qualified_name) { 'grimoires' }
        let(:parameters)     { super().merge(qualified_name:) }
        let(:expected) do
          super().merge(
            entity_class:   'Grimoire',
            qualified_name:
          )
        end

        it { expect(call_method(**parameters)).to be == expected }
      end

      describe 'with qualified_name: a Symbol' do
        let(:qualified_name) { :grimoires }
        let(:parameters)     { super().merge(qualified_name:) }
        let(:expected) do
          super().merge(
            entity_class:   'Grimoire',
            qualified_name: qualified_name.to_s
          )
        end

        it { expect(call_method(**parameters)).to be == expected }
      end

      describe 'with singular_name: a String' do
        let(:singular_name) { 'grimoire' }
        let(:parameters)  { super().merge(singular_name:) }
        let(:expected)    { super().merge(singular_name:) }

        it { expect(call_method(**parameters)).to be == expected }
      end

      describe 'with singular_name: a Symbol' do
        let(:singular_name) { :grimoire }
        let(:parameters)  { super().merge(singular_name:) }
        let(:expected)    { super().merge(singular_name: singular_name.to_s) }

        it { expect(call_method(**parameters)).to be == expected }
      end
    end

    describe 'with name: a singular Symbol' do
      let(:name)         { :book }
      let(:parameters)   { { name: } }
      let(:expected) do
        {
          entity_class:   'Book',
          name:           'book',
          plural_name:    'books',
          qualified_name: 'books',
          singular_name:  'book'
        }
      end

      it { expect(call_method(**parameters)).to be == expected }

      describe 'with entity_class: a Class' do
        let(:entity_class) { Grimoire }
        let(:parameters)   { super().merge(entity_class:) }
        let(:expected) do
          super().merge(
            entity_class:,
            qualified_name: 'grimoires'
          )
        end

        it { expect(call_method(**parameters)).to be == expected }
      end

      describe 'with entity_class: a scoped Class' do
        let(:entity_class) { Spec::ScopedBook }
        let(:parameters)   { super().merge(entity_class:) }
        let(:expected) do
          super().merge(
            entity_class:,
            qualified_name: 'spec/scoped_books'
          )
        end

        it { expect(call_method(**parameters)).to be == expected }
      end

      describe 'with entity_class: a String' do
        let(:entity_class) { 'Grimoire' }
        let(:parameters)   { super().merge(entity_class:) }
        let(:expected) do
          super().merge(
            entity_class:,
            qualified_name: 'grimoires'
          )
        end

        it { expect(call_method(**parameters)).to be == expected }
      end

      describe 'with entity_class: a scoped String' do
        let(:entity_class) { 'Spec::ScopedBook' }
        let(:parameters)   { super().merge(entity_class:) }
        let(:expected) do
          super().merge(
            entity_class:,
            qualified_name: 'spec/scoped_books'
          )
        end

        it { expect(call_method(**parameters)).to be == expected }
      end

      describe 'with plural_name: a String' do
        let(:plural_name) { 'grimoires' }
        let(:parameters)  { super().merge(plural_name:) }
        let(:expected)    { super().merge(plural_name:) }

        it { expect(call_method(**parameters)).to be == expected }
      end

      describe 'with plural_name: a Symbol' do
        let(:plural_name) { :grimoires }
        let(:parameters)  { super().merge(plural_name:) }
        let(:expected)    { super().merge(plural_name: plural_name.to_s) }

        it { expect(call_method(**parameters)).to be == expected }
      end

      describe 'with qualified_name: a String' do
        let(:qualified_name) { 'grimoires' }
        let(:parameters)     { super().merge(qualified_name:) }
        let(:expected) do
          super().merge(
            entity_class:   'Grimoire',
            qualified_name:
          )
        end

        it { expect(call_method(**parameters)).to be == expected }
      end

      describe 'with qualified_name: a Symbol' do
        let(:qualified_name) { :grimoires }
        let(:parameters)     { super().merge(qualified_name:) }
        let(:expected) do
          super().merge(
            entity_class:   'Grimoire',
            qualified_name: qualified_name.to_s
          )
        end

        it { expect(call_method(**parameters)).to be == expected }
      end

      describe 'with singular_name: a String' do
        let(:singular_name) { 'grimoire' }
        let(:parameters)  { super().merge(singular_name:) }
        let(:expected)    { super().merge(singular_name:) }

        it { expect(call_method(**parameters)).to be == expected }
      end

      describe 'with singular_name: a Symbol' do
        let(:singular_name) { :grimoire }
        let(:parameters)  { super().merge(singular_name:) }
        let(:expected)    { super().merge(singular_name: singular_name.to_s) }

        it { expect(call_method(**parameters)).to be == expected }
      end
    end

    describe 'with name: an uncountable String' do
      let(:name)         { 'data' }
      let(:parameters)   { { name: } }
      let(:expected) do
        {
          entity_class:   'Data',
          name:           'data',
          plural_name:    'data',
          qualified_name: 'data',
          singular_name:  'data'
        }
      end

      it { expect(call_method(**parameters)).to be == expected }

      describe 'with entity_class: a Class' do
        let(:entity_class) { Grimoire }
        let(:parameters)   { super().merge(entity_class:) }
        let(:expected) do
          super().merge(
            entity_class:,
            qualified_name: 'grimoires'
          )
        end

        it { expect(call_method(**parameters)).to be == expected }
      end

      describe 'with entity_class: a scoped Class' do
        let(:entity_class) { Spec::ScopedBook }
        let(:parameters)   { super().merge(entity_class:) }
        let(:expected) do
          super().merge(
            entity_class:,
            qualified_name: 'spec/scoped_books'
          )
        end

        it { expect(call_method(**parameters)).to be == expected }
      end

      describe 'with entity_class: a String' do
        let(:entity_class) { 'Grimoire' }
        let(:parameters)   { super().merge(entity_class:) }
        let(:expected) do
          super().merge(
            entity_class:,
            qualified_name: 'grimoires'
          )
        end

        it { expect(call_method(**parameters)).to be == expected }
      end

      describe 'with entity_class: a scoped String' do
        let(:entity_class) { 'Spec::ScopedBook' }
        let(:parameters)   { super().merge(entity_class:) }
        let(:expected) do
          super().merge(
            entity_class:,
            qualified_name: 'spec/scoped_books'
          )
        end

        it { expect(call_method(**parameters)).to be == expected }
      end

      describe 'with plural_name: a String' do
        let(:plural_name) { 'grimoires' }
        let(:parameters)  { super().merge(plural_name:) }
        let(:expected)    { super().merge(plural_name:) }

        it { expect(call_method(**parameters)).to be == expected }
      end

      describe 'with plural_name: a Symbol' do
        let(:plural_name) { :grimoires }
        let(:parameters)  { super().merge(plural_name:) }
        let(:expected)    { super().merge(plural_name: plural_name.to_s) }

        it { expect(call_method(**parameters)).to be == expected }
      end

      describe 'with qualified_name: a String' do
        let(:qualified_name) { 'grimoires' }
        let(:parameters)     { super().merge(qualified_name:) }
        let(:expected) do
          super().merge(
            entity_class:   'Grimoire',
            qualified_name:
          )
        end

        it { expect(call_method(**parameters)).to be == expected }
      end

      describe 'with qualified_name: a Symbol' do
        let(:qualified_name) { :grimoires }
        let(:parameters)     { super().merge(qualified_name:) }
        let(:expected) do
          super().merge(
            entity_class:   'Grimoire',
            qualified_name: qualified_name.to_s
          )
        end

        it { expect(call_method(**parameters)).to be == expected }
      end

      describe 'with singular_name: a String' do
        let(:singular_name) { 'grimoire' }
        let(:parameters)  { super().merge(singular_name:) }
        let(:expected)    { super().merge(singular_name:) }

        it { expect(call_method(**parameters)).to be == expected }
      end

      describe 'with singular_name: a Symbol' do
        let(:singular_name) { :grimoire }
        let(:parameters)  { super().merge(singular_name:) }
        let(:expected)    { super().merge(singular_name: singular_name.to_s) }

        it { expect(call_method(**parameters)).to be == expected }
      end
    end

    describe 'with name: an uncountable Symbol' do
      let(:name)         { :data }
      let(:parameters)   { { name: } }
      let(:expected) do
        {
          entity_class:   'Data',
          name:           'data',
          plural_name:    'data',
          qualified_name: 'data',
          singular_name:  'data'
        }
      end

      it { expect(call_method(**parameters)).to be == expected }

      describe 'with entity_class: a Class' do
        let(:entity_class) { Grimoire }
        let(:parameters)   { super().merge(entity_class:) }
        let(:expected) do
          super().merge(
            entity_class:,
            qualified_name: 'grimoires'
          )
        end

        it { expect(call_method(**parameters)).to be == expected }
      end

      describe 'with entity_class: a scoped Class' do
        let(:entity_class) { Spec::ScopedBook }
        let(:parameters)   { super().merge(entity_class:) }
        let(:expected) do
          super().merge(
            entity_class:,
            qualified_name: 'spec/scoped_books'
          )
        end

        it { expect(call_method(**parameters)).to be == expected }
      end

      describe 'with entity_class: a String' do
        let(:entity_class) { 'Grimoire' }
        let(:parameters)   { super().merge(entity_class:) }
        let(:expected) do
          super().merge(
            entity_class:,
            qualified_name: 'grimoires'
          )
        end

        it { expect(call_method(**parameters)).to be == expected }
      end

      describe 'with entity_class: a scoped String' do
        let(:entity_class) { 'Spec::ScopedBook' }
        let(:parameters)   { super().merge(entity_class:) }
        let(:expected) do
          super().merge(
            entity_class:,
            qualified_name: 'spec/scoped_books'
          )
        end

        it { expect(call_method(**parameters)).to be == expected }
      end

      describe 'with plural_name: a String' do
        let(:plural_name) { 'grimoires' }
        let(:parameters)  { super().merge(plural_name:) }
        let(:expected)    { super().merge(plural_name:) }

        it { expect(call_method(**parameters)).to be == expected }
      end

      describe 'with plural_name: a Symbol' do
        let(:plural_name) { :grimoires }
        let(:parameters)  { super().merge(plural_name:) }
        let(:expected)    { super().merge(plural_name: plural_name.to_s) }

        it { expect(call_method(**parameters)).to be == expected }
      end

      describe 'with qualified_name: a String' do
        let(:qualified_name) { 'grimoires' }
        let(:parameters)     { super().merge(qualified_name:) }
        let(:expected) do
          super().merge(
            entity_class:   'Grimoire',
            qualified_name:
          )
        end

        it { expect(call_method(**parameters)).to be == expected }
      end

      describe 'with qualified_name: a Symbol' do
        let(:qualified_name) { :grimoires }
        let(:parameters)     { super().merge(qualified_name:) }
        let(:expected) do
          super().merge(
            entity_class:   'Grimoire',
            qualified_name: qualified_name.to_s
          )
        end

        it { expect(call_method(**parameters)).to be == expected }
      end

      describe 'with singular_name: a String' do
        let(:singular_name) { 'grimoire' }
        let(:parameters)  { super().merge(singular_name:) }
        let(:expected)    { super().merge(singular_name:) }

        it { expect(call_method(**parameters)).to be == expected }
      end

      describe 'with singular_name: a Symbol' do
        let(:singular_name) { :grimoire }
        let(:parameters)  { super().merge(singular_name:) }
        let(:expected)    { super().merge(singular_name: singular_name.to_s) }

        it { expect(call_method(**parameters)).to be == expected }
      end
    end
  end

  describe '#resolve_parameters' do
    let(:parameters) do
      {
        entity_class:   Book,
        name:           'books',
        qualified_name: 'spec/scoped_books',
        singular_name:  'grimoire'
      }
    end
    let(:resolved) { parameters.merge(ok: true) }

    before(:example) do
      allow(concern)
        .to receive(:resolve_parameters)
        .and_return(resolved)
    end

    it 'should define the method' do
      expect(relation).to respond_to(:resolve_parameters).with(1).argument
    end

    it 'should delegate to the class method', :aggregate_failures do
      expect(relation.resolve_parameters(parameters)).to be == resolved

      expect(concern)
        .to have_received(:resolve_parameters)
        .with(parameters)
    end
  end
end
