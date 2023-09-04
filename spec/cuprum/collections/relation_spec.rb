# frozen_string_literal: true

require 'cuprum/collections/relation'
require 'cuprum/collections/rspec/contracts/relation_contracts'

RSpec.describe Cuprum::Collections::Relation do
  include Cuprum::Collections::RSpec::Contracts::RelationContracts

  subject(:relation) { described_class.new(**constructor_options) }

  let(:name)                { 'books' }
  let(:constructor_options) { { name: name } }

  example_class 'Book'
  example_class 'Grimoire',         'Book'
  example_class 'Spec::ScopedBook', 'Book'

  describe '::Parameters' do
    subject(:relation) do
      Class.new { include Cuprum::Collections::Relation::Parameters }.new
    end

    let(:described_class) { super()::Parameters }

    describe '.resolve_parameters' do
      let(:parameters) { {} }
      let(:resolved)   { described_class.resolve_parameters(**parameters) }

      def call_method(**parameters)
        described_class.resolve_parameters(parameters)
      end

      it 'should define the class method' do
        expect(described_class)
          .to respond_to(:resolve_parameters)
          .with(1).argument
      end

      include_contract 'should validate the parameters'

      describe 'with entity_class: a Class' do
        let(:entity_class) { Book }
        let(:parameters)   { { entity_class: entity_class } }
        let(:expected) do
          {
            entity_class:   Book,
            singular_name:  'book',
            name:           'books',
            qualified_name: 'books'
          }
        end

        it { expect(resolved).to be == expected }

        describe 'with name: a String' do
          let(:name)       { 'grimoires' }
          let(:parameters) { super().merge(name: name) }
          let(:expected) do
            super().merge(name: name, singular_name: 'grimoire')
          end

          it { expect(resolved).to be == expected }
        end

        describe 'with name: a Symbol' do
          let(:name)       { :grimoires }
          let(:parameters) { super().merge(name: name) }
          let(:expected) do
            super().merge(name: name.to_s, singular_name: 'grimoire')
          end

          it { expect(resolved).to be == expected }
        end

        describe 'with qualified_name: a String' do
          let(:qualified_name) { 'grimoires' }
          let(:parameters)     { super().merge(qualified_name: qualified_name) }
          let(:expected)       { super().merge(qualified_name: qualified_name) }

          it { expect(resolved).to be == expected }
        end

        describe 'with qualified_name: a Symbol' do
          let(:qualified_name) { 'grimoires' }
          let(:parameters)     { super().merge(qualified_name: qualified_name) }
          let(:expected) do
            super().merge(qualified_name: qualified_name.to_s)
          end

          it { expect(resolved).to be == expected }
        end

        describe 'with singular_name: a String' do
          let(:singular_name) { 'grimoire' }
          let(:parameters)  { super().merge(singular_name: singular_name) }
          let(:expected)    { super().merge(singular_name: singular_name) }

          it { expect(resolved).to be == expected }
        end

        describe 'with singular_name: a Symbol' do
          let(:singular_name) { :grimoire }
          let(:parameters)  { super().merge(singular_name: singular_name) }
          let(:expected)    { super().merge(singular_name: singular_name.to_s) }

          it { expect(resolved).to be == expected }
        end
      end

      describe 'with entity_class: a scoped Class' do
        let(:entity_class) { Spec::ScopedBook }
        let(:parameters)   { { entity_class: entity_class } }
        let(:expected) do
          {
            entity_class:   Spec::ScopedBook,
            singular_name:  'scoped_book',
            name:           'scoped_books',
            qualified_name: 'spec/scoped_books'
          }
        end

        it { expect(resolved).to be == expected }

        describe 'with name: a String' do
          let(:name)       { 'grimoires' }
          let(:parameters) { super().merge(name: name) }
          let(:expected) do
            super().merge(name: name, singular_name: 'grimoire')
          end

          it { expect(resolved).to be == expected }
        end

        describe 'with name: a Symbol' do
          let(:name)       { :grimoires }
          let(:parameters) { super().merge(name: name) }
          let(:expected) do
            super().merge(name: name.to_s, singular_name: 'grimoire')
          end

          it { expect(resolved).to be == expected }
        end

        describe 'with qualified_name: a String' do
          let(:qualified_name) { 'grimoires' }
          let(:parameters)     { super().merge(qualified_name: qualified_name) }
          let(:expected)       { super().merge(qualified_name: qualified_name) }

          it { expect(resolved).to be == expected }
        end

        describe 'with qualified_name: a Symbol' do
          let(:qualified_name) { 'grimoires' }
          let(:parameters)     { super().merge(qualified_name: qualified_name) }
          let(:expected) do
            super().merge(qualified_name: qualified_name.to_s)
          end

          it { expect(resolved).to be == expected }
        end

        describe 'with singular_name: a String' do
          let(:singular_name) { 'grimoire' }
          let(:parameters)  { super().merge(singular_name: singular_name) }
          let(:expected)    { super().merge(singular_name: singular_name) }

          it { expect(resolved).to be == expected }
        end

        describe 'with singular_name: a Symbol' do
          let(:singular_name) { :grimoire }
          let(:parameters)  { super().merge(singular_name: singular_name) }
          let(:expected)    { super().merge(singular_name: singular_name.to_s) }

          it { expect(resolved).to be == expected }
        end
      end

      describe 'with entity_class: a String' do
        let(:entity_class) { 'Book' }
        let(:parameters)   { { entity_class: entity_class } }
        let(:expected) do
          {
            entity_class:   'Book',
            singular_name:  'book',
            name:           'books',
            qualified_name: 'books'
          }
        end

        it { expect(resolved).to be == expected }

        describe 'with name: a String' do
          let(:name)       { 'grimoires' }
          let(:parameters) { super().merge(name: name) }
          let(:expected) do
            super().merge(name: name, singular_name: 'grimoire')
          end

          it { expect(resolved).to be == expected }
        end

        describe 'with name: a Symbol' do
          let(:name)       { :grimoires }
          let(:parameters) { super().merge(name: name) }
          let(:expected) do
            super().merge(name: name.to_s, singular_name: 'grimoire')
          end

          it { expect(resolved).to be == expected }
        end

        describe 'with qualified_name: a String' do
          let(:qualified_name) { 'grimoires' }
          let(:parameters)     { super().merge(qualified_name: qualified_name) }
          let(:expected)       { super().merge(qualified_name: qualified_name) }

          it { expect(resolved).to be == expected }
        end

        describe 'with qualified_name: a Symbol' do
          let(:qualified_name) { 'grimoires' }
          let(:parameters)     { super().merge(qualified_name: qualified_name) }
          let(:expected) do
            super().merge(qualified_name: qualified_name.to_s)
          end

          it { expect(resolved).to be == expected }
        end

        describe 'with singular_name: a String' do
          let(:singular_name) { 'grimoire' }
          let(:parameters)  { super().merge(singular_name: singular_name) }
          let(:expected)    { super().merge(singular_name: singular_name) }

          it { expect(resolved).to be == expected }
        end

        describe 'with singular_name: a Symbol' do
          let(:singular_name) { :grimoire }
          let(:parameters)  { super().merge(singular_name: singular_name) }
          let(:expected)    { super().merge(singular_name: singular_name.to_s) }

          it { expect(resolved).to be == expected }
        end
      end

      describe 'with entity_class: a scoped String' do
        let(:entity_class) { 'Spec::ScopedBook' }
        let(:parameters)   { { entity_class: entity_class } }
        let(:expected) do
          {
            entity_class:   'Spec::ScopedBook',
            singular_name:  'scoped_book',
            name:           'scoped_books',
            qualified_name: 'spec/scoped_books'
          }
        end

        it { expect(resolved).to be == expected }

        describe 'with name: a String' do
          let(:name)       { 'grimoires' }
          let(:parameters) { super().merge(name: name) }
          let(:expected) do
            super().merge(name: name, singular_name: 'grimoire')
          end

          it { expect(resolved).to be == expected }
        end

        describe 'with name: a Symbol' do
          let(:name)       { :grimoires }
          let(:parameters) { super().merge(name: name) }
          let(:expected) do
            super().merge(name: name.to_s, singular_name: 'grimoire')
          end

          it { expect(resolved).to be == expected }
        end

        describe 'with qualified_name: a String' do
          let(:qualified_name) { 'grimoires' }
          let(:parameters)     { super().merge(qualified_name: qualified_name) }
          let(:expected)       { super().merge(qualified_name: qualified_name) }

          it { expect(resolved).to be == expected }
        end

        describe 'with qualified_name: a Symbol' do
          let(:qualified_name) { 'grimoires' }
          let(:parameters)     { super().merge(qualified_name: qualified_name) }
          let(:expected) do
            super().merge(qualified_name: qualified_name.to_s)
          end

          it { expect(resolved).to be == expected }
        end

        describe 'with singular_name: a String' do
          let(:singular_name) { 'grimoire' }
          let(:parameters)  { super().merge(singular_name: singular_name) }
          let(:expected)    { super().merge(singular_name: singular_name) }

          it { expect(resolved).to be == expected }
        end

        describe 'with singular_name: a Symbol' do
          let(:singular_name) { :grimoire }
          let(:parameters)  { super().merge(singular_name: singular_name) }
          let(:expected)    { super().merge(singular_name: singular_name.to_s) }

          it { expect(resolved).to be == expected }
        end
      end

      describe 'with name: a String' do
        let(:name)         { 'books' }
        let(:parameters)   { { name: name } }
        let(:expected) do
          {
            entity_class:   'Book',
            singular_name:  'book',
            name:           'books',
            qualified_name: 'books'
          }
        end

        it { expect(resolved).to be == expected }

        describe 'with entity_class: a Class' do
          let(:entity_class) { Grimoire }
          let(:parameters)   { super().merge(entity_class: entity_class) }
          let(:expected) do
            super().merge(
              entity_class:   entity_class,
              qualified_name: 'grimoires'
            )
          end

          it { expect(resolved).to be == expected }
        end

        describe 'with entity_class: a scoped Class' do
          let(:entity_class) { Spec::ScopedBook }
          let(:parameters)   { super().merge(entity_class: entity_class) }
          let(:expected) do
            super().merge(
              entity_class:   entity_class,
              qualified_name: 'spec/scoped_books'
            )
          end

          it { expect(resolved).to be == expected }
        end

        describe 'with entity_class: a String' do
          let(:entity_class) { 'Grimoire' }
          let(:parameters)   { super().merge(entity_class: entity_class) }
          let(:expected) do
            super().merge(
              entity_class:   entity_class,
              qualified_name: 'grimoires'
            )
          end

          it { expect(resolved).to be == expected }
        end

        describe 'with entity_class: a scoped String' do
          let(:entity_class) { 'Spec::ScopedBook' }
          let(:parameters)   { super().merge(entity_class: entity_class) }
          let(:expected) do
            super().merge(
              entity_class:   entity_class,
              qualified_name: 'spec/scoped_books'
            )
          end

          it { expect(resolved).to be == expected }
        end

        describe 'with qualified_name: a String' do
          let(:qualified_name) { 'grimoires' }
          let(:parameters)     { super().merge(qualified_name: qualified_name) }
          let(:expected) do
            super().merge(
              entity_class:   'Grimoire',
              qualified_name: qualified_name
            )
          end

          it { expect(resolved).to be == expected }
        end

        describe 'with qualified_name: a Symbol' do
          let(:qualified_name) { :grimoires }
          let(:parameters)     { super().merge(qualified_name: qualified_name) }
          let(:expected) do
            super().merge(
              entity_class:   'Grimoire',
              qualified_name: qualified_name.to_s
            )
          end

          it { expect(resolved).to be == expected }
        end

        describe 'with singular_name: a String' do
          let(:singular_name) { 'grimoire' }
          let(:parameters)  { super().merge(singular_name: singular_name) }
          let(:expected)    { super().merge(singular_name: singular_name) }

          it { expect(resolved).to be == expected }
        end

        describe 'with singular_name: a Symbol' do
          let(:singular_name) { :grimoire }
          let(:parameters)  { super().merge(singular_name: singular_name) }
          let(:expected)    { super().merge(singular_name: singular_name.to_s) }

          it { expect(resolved).to be == expected }
        end
      end

      describe 'with name: a Symbol' do
        let(:name)         { :books }
        let(:parameters)   { { name: name } }
        let(:expected) do
          {
            entity_class:   'Book',
            singular_name:  'book',
            name:           'books',
            qualified_name: 'books'
          }
        end

        it { expect(resolved).to be == expected }

        describe 'with entity_class: a Class' do
          let(:entity_class) { Grimoire }
          let(:parameters)   { super().merge(entity_class: entity_class) }
          let(:expected) do
            super().merge(
              entity_class:   entity_class,
              qualified_name: 'grimoires'
            )
          end

          it { expect(resolved).to be == expected }
        end

        describe 'with entity_class: a scoped Class' do
          let(:entity_class) { Spec::ScopedBook }
          let(:parameters)   { super().merge(entity_class: entity_class) }
          let(:expected) do
            super().merge(
              entity_class:   entity_class,
              qualified_name: 'spec/scoped_books'
            )
          end

          it { expect(resolved).to be == expected }
        end

        describe 'with entity_class: a String' do
          let(:entity_class) { 'Grimoire' }
          let(:parameters)   { super().merge(entity_class: entity_class) }
          let(:expected) do
            super().merge(
              entity_class:   entity_class,
              qualified_name: 'grimoires'
            )
          end

          it { expect(resolved).to be == expected }
        end

        describe 'with entity_class: a scoped String' do
          let(:entity_class) { 'Spec::ScopedBook' }
          let(:parameters)   { super().merge(entity_class: entity_class) }
          let(:expected) do
            super().merge(
              entity_class:   entity_class,
              qualified_name: 'spec/scoped_books'
            )
          end

          it { expect(resolved).to be == expected }
        end

        describe 'with qualified_name: a String' do
          let(:qualified_name) { 'grimoires' }
          let(:parameters)     { super().merge(qualified_name: qualified_name) }
          let(:expected) do
            super().merge(
              entity_class:   'Grimoire',
              qualified_name: qualified_name
            )
          end

          it { expect(resolved).to be == expected }
        end

        describe 'with qualified_name: a Symbol' do
          let(:qualified_name) { :grimoires }
          let(:parameters)     { super().merge(qualified_name: qualified_name) }
          let(:expected) do
            super().merge(
              entity_class:   'Grimoire',
              qualified_name: qualified_name.to_s
            )
          end

          it { expect(resolved).to be == expected }
        end

        describe 'with singular_name: a String' do
          let(:singular_name) { 'grimoire' }
          let(:parameters)  { super().merge(singular_name: singular_name) }
          let(:expected)    { super().merge(singular_name: singular_name) }

          it { expect(resolved).to be == expected }
        end

        describe 'with singular_name: a Symbol' do
          let(:singular_name) { :grimoire }
          let(:parameters)  { super().merge(singular_name: singular_name) }
          let(:expected)    { super().merge(singular_name: singular_name.to_s) }

          it { expect(resolved).to be == expected }
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
        allow(described_class)
          .to receive(:resolve_parameters)
          .and_return(resolved)
      end

      it 'should define the method' do
        expect(relation).to respond_to(:resolve_parameters).with(1).argument
      end

      it 'should delegate to the class method', :aggregate_failures do
        expect(relation.resolve_parameters(parameters)).to be == resolved

        expect(described_class)
          .to have_received(:resolve_parameters)
          .with(parameters)
      end
    end
  end

  include_contract 'should be a relation'
end
