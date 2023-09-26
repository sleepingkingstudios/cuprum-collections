# frozen_string_literal: true

require 'cuprum/collections/relation'
require 'cuprum/collections/rspec/contracts/relation_contracts'

require 'support/book'
require 'support/grimoire'
require 'support/scoped_book'

RSpec.describe Cuprum::Collections::Relation do
  include Cuprum::Collections::RSpec::Contracts::RelationContracts

  subject(:relation) { described_class.new(**constructor_options) }

  let(:name)                { 'books' }
  let(:constructor_options) { { name: name } }

  describe '::Cardinality' do
    subject(:relation) { described_class.new(**constructor_options) }

    let(:described_class)     { Spec::ExampleRelation }
    let(:constructor_options) { {} }

    example_class 'Spec::ExampleRelation' do |klass|
      klass.include Cuprum::Collections::Relation::Cardinality

      klass.define_method(:initialize) do |**options|
        @plural = resolve_plurality(**options)
      end
    end

    include_contract 'should define cardinality'
  end

  describe '::Disambiguation' do
    subject(:relation) do
      Class.new { include Cuprum::Collections::Relation::Disambiguation }.new
    end

    let(:described_class) { super()::Disambiguation }

    describe '.disambiguate_keyword' do
      let(:keywords)     { {} }
      let(:key)          { :original_key }
      let(:alternatives) { [] }

      def disambiguate
        described_class.disambiguate_keyword(keywords, key, *alternatives)
      end

      it 'should define the class method' do
        expect(described_class)
          .to respond_to(:disambiguate_keyword)
          .with(2).arguments
          .and_unlimited_arguments
      end

      describe 'with no alternative keys' do
        let(:alternatives) { [] }

        it { expect(disambiguate).to be == keywords }

        describe 'with keywords' do
          let(:keywords) do
            {
              original_key: 'original value',
              custom_key:   'custom value'
            }
          end

          it { expect(disambiguate).to be == keywords }
        end
      end

      describe 'with one alternative key' do
        let(:alternatives) { :alternate_key }

        it { expect(disambiguate).to be == keywords }

        describe 'with keywords: no matching keys' do
          let(:keywords) do
            {
              custom_key: 'custom value'
            }
          end

          it { expect(disambiguate).to be == keywords }
        end

        describe 'with keywords: { original key: value }' do
          let(:keywords) do
            {
              original_key: 'original value',
              custom_key:   'custom value'
            }
          end

          it { expect(disambiguate).to be == keywords }
        end

        describe 'with keywords: { alternate key: value }' do
          let(:keywords) do
            {
              alternate_key: 'alternate value',
              custom_key:    'custom value'
            }
          end
          let(:expected) do
            {
              original_key: 'alternate value',
              custom_key:   'custom value'
            }
          end

          it { expect(disambiguate).to be == expected }
        end

        describe 'with ambiguous keywords' do
          let(:keywords) do
            {
              original_key:  'original value',
              alternate_key: 'alternate value',
              custom_key:    'custom value'
            }
          end
          let(:error_message) do
            "ambiguous parameter #{key}: initialized with parameters " \
              "#{key}: #{keywords[key].inspect}, " \
              "#{alternatives}: #{keywords[alternatives].inspect}"
          end

          it 'should raise an exception' do
            expect { disambiguate }
              .to raise_error ArgumentError, error_message
          end
        end
      end

      describe 'with multiple alternative keys' do
        let(:alternatives) { %i[alternate_key fallback_key] }

        it { expect(disambiguate).to be == keywords }

        describe 'with keywords: { original key: value }' do
          let(:keywords) do
            {
              original_key: 'original value',
              custom_key:   'custom value'
            }
          end

          it { expect(disambiguate).to be == keywords }
        end

        describe 'with keywords: { alternate key: value }' do
          let(:keywords) do
            {
              alternate_key: 'alternate value',
              custom_key:    'custom value'
            }
          end
          let(:expected) do
            {
              original_key: 'alternate value',
              custom_key:   'custom value'
            }
          end

          it { expect(disambiguate).to be == expected }
        end

        describe 'with keywords: { fallback key: value }' do
          let(:keywords) do
            {
              fallback_key: 'fallback value',
              custom_key:   'custom value'
            }
          end
          let(:expected) do
            {
              original_key: 'fallback value',
              custom_key:   'custom value'
            }
          end

          it { expect(disambiguate).to be == expected }
        end

        describe 'with ambiguous keywords' do
          let(:keywords) do
            {
              original_key:  'original value',
              alternate_key: 'alternate value',
              fallback_key:  'fallback value',
              custom_key:    'custom value'
            }
          end
          let(:error_message) do
            values = alternatives.map { |alt| keywords[alt] }

            "ambiguous parameter #{key}: initialized with parameters " \
              "#{key}: #{keywords[key].inspect}, " \
              "#{alternatives.first}: #{values.first.inspect}, " \
              "#{alternatives.last}: #{values.last.inspect}"
          end

          it 'should raise an exception' do
            expect { disambiguate }
              .to raise_error ArgumentError, error_message
          end
        end
      end
    end

    describe '.resolve_parameters' do
      let(:parameters) { { name: 'books' } }
      let(:ambiguous)  { {} }
      let(:resolved) do
        described_class.resolve_parameters(parameters, **ambiguous)
      end
      let(:expected) do
        parameters.merge({ ok: true })
      end

      before(:example) do
        allow(Cuprum::Collections::Relation::Parameters)
          .to receive(:resolve_parameters)
          .and_return(expected)
      end

      it 'should define the class method' do
        expect(described_class)
          .to respond_to(:resolve_parameters)
          .with(1).argument
          .and_any_keywords
      end

      describe 'with no ambiguous keywords' do
        let(:ambiguous) { {} }

        it 'should delegate to Parameters', :aggregate_failures do
          expect(resolved).to be == expected

          expect(Cuprum::Collections::Relation::Parameters)
            .to have_received(:resolve_parameters)
            .with(parameters)
        end
      end

      describe 'with one ambiguous keyword' do
        let(:parameters) { { name: 'books', member_name: 'grimoire' } }
        let(:ambiguous)  { { singular_name: %i[member_name item_name] } }
        let(:received)   { { name: 'books', singular_name: 'grimoire' } }
        let(:expected)   { received.merge(ok: true) }

        it 'should delegate to Parameters', :aggregate_failures do
          expect(resolved).to be == expected

          expect(Cuprum::Collections::Relation::Parameters)
            .to have_received(:resolve_parameters)
            .with(received)
        end
      end

      describe 'with many ambiguous keywords' do
        let(:parameters) do
          {
            name:        'books',
            member_name: 'grimoire',
            scoped_name: 'spec/scoped_books'
          }
        end
        let(:ambiguous) do
          {
            qualified_name: :scoped_name,
            singular_name:  %i[member_name item_name]
          }
        end
        let(:received) do
          {
            name:           'books',
            qualified_name: 'spec/scoped_books',
            singular_name:  'grimoire'
          }
        end
        let(:expected) { received.merge(ok: true) }

        it 'should delegate to Parameters', :aggregate_failures do
          expect(resolved).to be == expected

          expect(Cuprum::Collections::Relation::Parameters)
            .to have_received(:resolve_parameters)
            .with(received)
        end
      end
    end

    describe '#disambiguate_keyword' do
      let(:keywords) do
        {
          original_key: 'original value',
          custom_key:   'custom value'
        }
      end
      let(:key)           { :original_key }
      let(:alternatives)  { %i[alternate_key fallback_key] }
      let(:disambiguated) { keywords.merge(ok: true) }

      before(:example) do
        allow(described_class)
          .to receive(:disambiguate_keyword)
          .and_return(disambiguated)
      end

      it 'should define the method' do
        expect(relation)
          .to respond_to(:disambiguate_keyword)
          .with(2).arguments
          .and_unlimited_arguments
      end

      it 'should delegate to the class method', :aggregate_failures do
        expect(relation.disambiguate_keyword(keywords, key, *alternatives))
          .to be == disambiguated

        expect(described_class)
          .to have_received(:disambiguate_keyword)
          .with(keywords, key, *alternatives)
      end
    end

    describe '#resolve_parameters' do
      let(:parameters) { { collection_name: 'books' } }
      let(:ambiguous)  { { name: :collection_name } }
      let(:resolved) do
        relation.resolve_parameters(parameters, **ambiguous)
      end
      let(:expected) do
        parameters.merge({ ok: true })
      end

      before(:example) do
        allow(described_class)
          .to receive(:resolve_parameters)
          .and_return(expected)
      end

      it 'should define the method' do
        expect(relation)
          .to respond_to(:resolve_parameters)
          .with(1).argument
          .and_any_keywords
      end

      it 'should delegate to the class method', :aggregate_failures do
        expect(resolved).to be == expected

        expect(described_class)
          .to have_received(:resolve_parameters)
          .with(parameters, **ambiguous)
      end
    end
  end

  describe '::Parameters' do
    subject(:relation) do
      Class.new { include Cuprum::Collections::Relation::Parameters }.new
    end

    let(:described_class) { super()::Parameters }

    describe '.resolve_parameters' do
      let(:parameters) { {} }
      let(:resolved)   { described_class.resolve_parameters(parameters) }

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
            name:           'books',
            plural_name:    'books',
            qualified_name: 'books',
            singular_name:  'book'
          }
        end

        it { expect(resolved).to be == expected }

        describe 'with name: a String' do
          let(:name)       { 'grimoires' }
          let(:parameters) { super().merge(name: name) }
          let(:expected) do
            super().merge(
              name:          name,
              plural_name:   'grimoires',
              singular_name: 'grimoire'
            )
          end

          it { expect(resolved).to be == expected }
        end

        describe 'with name: a Symbol' do
          let(:name)       { :grimoires }
          let(:parameters) { super().merge(name: name) }
          let(:expected) do
            super().merge(
              name:          name.to_s,
              plural_name:   'grimoires',
              singular_name: 'grimoire'
            )
          end

          it { expect(resolved).to be == expected }
        end

        describe 'with plural_name: a String' do
          let(:plural_name) { 'grimoires' }
          let(:parameters)  { super().merge(plural_name: plural_name) }
          let(:expected)    { super().merge(plural_name: plural_name) }

          it { expect(resolved).to be == expected }
        end

        describe 'with plural_name: a Symbol' do
          let(:plural_name) { :grimoire }
          let(:parameters)  { super().merge(plural_name: plural_name) }
          let(:expected)    { super().merge(plural_name: plural_name.to_s) }

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
            name:           'scoped_books',
            plural_name:    'scoped_books',
            qualified_name: 'spec/scoped_books',
            singular_name:  'scoped_book'
          }
        end

        it { expect(resolved).to be == expected }

        describe 'with name: a String' do
          let(:name)       { 'grimoires' }
          let(:parameters) { super().merge(name: name) }
          let(:expected) do
            super().merge(
              name:          name,
              plural_name:   'grimoires',
              singular_name: 'grimoire'
            )
          end

          it { expect(resolved).to be == expected }
        end

        describe 'with name: a Symbol' do
          let(:name)       { :grimoires }
          let(:parameters) { super().merge(name: name) }
          let(:expected) do
            super().merge(
              name:          name.to_s,
              plural_name:   'grimoires',
              singular_name: 'grimoire'
            )
          end

          it { expect(resolved).to be == expected }
        end

        describe 'with plural_name: a String' do
          let(:plural_name) { 'grimoires' }
          let(:parameters)  { super().merge(plural_name: plural_name) }
          let(:expected)    { super().merge(plural_name: plural_name) }

          it { expect(resolved).to be == expected }
        end

        describe 'with plural_name: a Symbol' do
          let(:plural_name) { :grimoire }
          let(:parameters)  { super().merge(plural_name: plural_name) }
          let(:expected)    { super().merge(plural_name: plural_name.to_s) }

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
            name:           'books',
            plural_name:    'books',
            qualified_name: 'books',
            singular_name:  'book'
          }
        end

        it { expect(resolved).to be == expected }

        describe 'with name: a String' do
          let(:name)       { 'grimoires' }
          let(:parameters) { super().merge(name: name) }
          let(:expected) do
            super().merge(
              name:          name,
              plural_name:   'grimoires',
              singular_name: 'grimoire'
            )
          end

          it { expect(resolved).to be == expected }
        end

        describe 'with name: a Symbol' do
          let(:name)       { :grimoires }
          let(:parameters) { super().merge(name: name) }
          let(:expected) do
            super().merge(
              name:          name.to_s,
              plural_name:   'grimoires',
              singular_name: 'grimoire'
            )
          end

          it { expect(resolved).to be == expected }
        end

        describe 'with plural_name: a String' do
          let(:plural_name) { 'grimoires' }
          let(:parameters)  { super().merge(plural_name: plural_name) }
          let(:expected)    { super().merge(plural_name: plural_name) }

          it { expect(resolved).to be == expected }
        end

        describe 'with plural_name: a Symbol' do
          let(:plural_name) { :grimoires }
          let(:parameters)  { super().merge(plural_name: plural_name) }
          let(:expected)    { super().merge(plural_name: plural_name.to_s) }

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
            name:           'scoped_books',
            plural_name:    'scoped_books',
            qualified_name: 'spec/scoped_books',
            singular_name:  'scoped_book'
          }
        end

        it { expect(resolved).to be == expected }

        describe 'with name: a String' do
          let(:name)       { 'grimoires' }
          let(:parameters) { super().merge(name: name) }
          let(:expected) do
            super().merge(
              name:          name,
              plural_name:   'grimoires',
              singular_name: 'grimoire'
            )
          end

          it { expect(resolved).to be == expected }
        end

        describe 'with name: a Symbol' do
          let(:name)       { :grimoires }
          let(:parameters) { super().merge(name: name) }
          let(:expected) do
            super().merge(
              name:          name.to_s,
              plural_name:   'grimoires',
              singular_name: 'grimoire'
            )
          end

          it { expect(resolved).to be == expected }
        end

        describe 'with plural_name: a String' do
          let(:plural_name) { 'grimoires' }
          let(:parameters)  { super().merge(plural_name: plural_name) }
          let(:expected)    { super().merge(plural_name: plural_name) }

          it { expect(resolved).to be == expected }
        end

        describe 'with plural_name: a Symbol' do
          let(:plural_name) { :grimoires }
          let(:parameters)  { super().merge(plural_name: plural_name) }
          let(:expected)    { super().merge(plural_name: plural_name.to_s) }

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
            name:           'books',
            plural_name:    'books',
            qualified_name: 'books',
            singular_name:  'book'
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

        describe 'with plural_name: a String' do
          let(:plural_name) { 'grimoires' }
          let(:parameters)  { super().merge(plural_name: plural_name) }
          let(:expected)    { super().merge(plural_name: plural_name) }

          it { expect(resolved).to be == expected }
        end

        describe 'with plural_name: a Symbol' do
          let(:plural_name) { :grimoires }
          let(:parameters)  { super().merge(plural_name: plural_name) }
          let(:expected)    { super().merge(plural_name: plural_name.to_s) }

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
            name:           'books',
            plural_name:    'books',
            qualified_name: 'books',
            singular_name:  'book'
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

        describe 'with plural_name: a String' do
          let(:plural_name) { 'grimoires' }
          let(:parameters)  { super().merge(plural_name: plural_name) }
          let(:expected)    { super().merge(plural_name: plural_name) }

          it { expect(resolved).to be == expected }
        end

        describe 'with plural_name: a Symbol' do
          let(:plural_name) { :grimoires }
          let(:parameters)  { super().merge(plural_name: plural_name) }
          let(:expected)    { super().merge(plural_name: plural_name.to_s) }

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

      describe 'with name: a singular String' do
        let(:name)         { 'book' }
        let(:parameters)   { { name: name } }
        let(:expected) do
          {
            entity_class:   'Book',
            name:           'book',
            plural_name:    'books',
            qualified_name: 'books',
            singular_name:  'book'
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

        describe 'with plural_name: a String' do
          let(:plural_name) { 'grimoires' }
          let(:parameters)  { super().merge(plural_name: plural_name) }
          let(:expected)    { super().merge(plural_name: plural_name) }

          it { expect(resolved).to be == expected }
        end

        describe 'with plural_name: a Symbol' do
          let(:plural_name) { :grimoires }
          let(:parameters)  { super().merge(plural_name: plural_name) }
          let(:expected)    { super().merge(plural_name: plural_name.to_s) }

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

      describe 'with name: a singular Symbol' do
        let(:name)         { :book }
        let(:parameters)   { { name: name } }
        let(:expected) do
          {
            entity_class:   'Book',
            name:           'book',
            plural_name:    'books',
            qualified_name: 'books',
            singular_name:  'book'
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

        describe 'with plural_name: a String' do
          let(:plural_name) { 'grimoires' }
          let(:parameters)  { super().merge(plural_name: plural_name) }
          let(:expected)    { super().merge(plural_name: plural_name) }

          it { expect(resolved).to be == expected }
        end

        describe 'with plural_name: a Symbol' do
          let(:plural_name) { :grimoires }
          let(:parameters)  { super().merge(plural_name: plural_name) }
          let(:expected)    { super().merge(plural_name: plural_name.to_s) }

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

      describe 'with name: an uncountable String' do
        let(:name)         { 'data' }
        let(:parameters)   { { name: name } }
        let(:expected) do
          {
            entity_class:   'Data',
            name:           'data',
            plural_name:    'data',
            qualified_name: 'data',
            singular_name:  'data'
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

        describe 'with plural_name: a String' do
          let(:plural_name) { 'grimoires' }
          let(:parameters)  { super().merge(plural_name: plural_name) }
          let(:expected)    { super().merge(plural_name: plural_name) }

          it { expect(resolved).to be == expected }
        end

        describe 'with plural_name: a Symbol' do
          let(:plural_name) { :grimoires }
          let(:parameters)  { super().merge(plural_name: plural_name) }
          let(:expected)    { super().merge(plural_name: plural_name.to_s) }

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

      describe 'with name: an uncountable Symbol' do
        let(:name)         { :data }
        let(:parameters)   { { name: name } }
        let(:expected) do
          {
            entity_class:   'Data',
            name:           'data',
            plural_name:    'data',
            qualified_name: 'data',
            singular_name:  'data'
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

        describe 'with plural_name: a String' do
          let(:plural_name) { 'grimoires' }
          let(:parameters)  { super().merge(plural_name: plural_name) }
          let(:expected)    { super().merge(plural_name: plural_name) }

          it { expect(resolved).to be == expected }
        end

        describe 'with plural_name: a Symbol' do
          let(:plural_name) { :grimoires }
          let(:parameters)  { super().merge(plural_name: plural_name) }
          let(:expected)    { super().merge(plural_name: plural_name.to_s) }

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

  describe '::PrimaryKeys' do
    subject(:relation) { described_class.new(**constructor_options) }

    let(:described_class)     { Spec::ExampleRelation }
    let(:constructor_options) { {} }

    example_class 'Spec::ExampleRelation' do |klass|
      klass.include Cuprum::Collections::Relation::PrimaryKeys

      klass.define_method(:initialize) { |**options| @options = options }

      klass.attr_reader :options
    end

    include_contract 'should define primary keys'
  end

  include_contract 'should be a relation'
end
