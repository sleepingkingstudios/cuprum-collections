# frozen_string_literal: true

require 'rspec/sleeping_king_studios/deferred'

require 'cuprum/collections/rspec/deferred'

module Cuprum::Collections::RSpec::Deferred
  # Deferred examples for testing relations.
  module RelationExamples
    include RSpec::SleepingKingStudios::Deferred::Provider

    deferred_examples 'should be a Relation' do |**options|
      if options.fetch(:constructor, true)
        describe '.new' do
          let(:expected_keywords) do
            keywords = %i[
              entity_class
              name
              plural_name
              qualified_name
              singular_name
            ]

            keywords += %i[plural singular] if options[:cardinality]

            keywords + options.fetch(:expected_keywords, [])
          end

          def call_method(**parameters)
            described_class.new(**parameters)
          end

          it 'should define the constructor' do
            expect(described_class)
              .to be_constructible
              .with(0).arguments
              .and_keywords(*expected_keywords)
              .and_any_keywords
          end

          include_deferred 'should validate the Relation parameters'
        end
      end

      describe '#entity_class' do
        include_examples 'should define reader', :entity_class

        context 'when initialized with entity_class: a Class' do
          let(:entity_class) { Grimoire }
          let(:constructor_options) do
            super()
              .tap { |hsh| hsh.delete(:name) }
              .merge(entity_class:)
          end

          it { expect(subject.entity_class).to be Grimoire }
        end

        context 'when initialized with entity_class: a scoped Class' do
          let(:entity_class) { Spec::ScopedBook }
          let(:constructor_options) do
            super()
              .tap { |hsh| hsh.delete(:name) }
              .merge(entity_class:)
          end

          it { expect(subject.entity_class).to be Spec::ScopedBook }
        end

        context 'when initialized with entity_class: a String' do
          let(:entity_class) { 'Grimoire' }
          let(:constructor_options) do
            super()
              .tap { |hsh| hsh.delete(:name) }
              .merge(entity_class:)
          end

          it { expect(subject.entity_class).to be Grimoire }
        end

        context 'when initialized with entity_class: a scoped String' do
          let(:entity_class) { 'Spec::ScopedBook' }
          let(:constructor_options) do
            super()
              .tap { |hsh| hsh.delete(:name) }
              .merge(entity_class:)
          end

          it { expect(subject.entity_class).to be Spec::ScopedBook }
        end

        context 'when initialized with name: a String' do
          let(:name) { 'books' }
          let(:constructor_options) do
            super().merge(name:)
          end
          let(:expected) { options[:default_entity_class] || Book }

          it { expect(subject.entity_class).to be expected }

          context 'when initialized with entity_class: value' do
            let(:entity_class) { Grimoire }
            let(:constructor_options) do
              super()
                .tap { |hsh| hsh.delete(:name) }
                .merge(entity_class:)
            end

            it { expect(subject.entity_class).to be Grimoire }
          end

          context 'when initialized with qualified_name: value' do
            let(:qualified_name) { 'spec/scoped_books' }
            let(:constructor_options) do
              super().merge(qualified_name:)
            end
            let(:expected) do
              options[:default_entity_class] || Spec::ScopedBook
            end

            it { expect(subject.entity_class).to be expected }

            context 'when initialized with entity_class: value' do
              let(:entity_class) { Grimoire }
              let(:constructor_options) do
                super()
                  .tap { |hsh| hsh.delete(:name) }
                  .merge(entity_class:)
              end

              it { expect(subject.entity_class).to be Grimoire }
            end
          end
        end

        context 'when initialized with name: a Symbol' do
          let(:name) { 'books' }
          let(:constructor_options) do
            super().merge(name:)
          end
          let(:expected) { options[:default_entity_class] || Book }

          it { expect(subject.entity_class).to be expected }

          context 'when initialized with entity_class: value' do
            let(:entity_class) { Grimoire }
            let(:constructor_options) do
              super()
                .tap { |hsh| hsh.delete(:name) }
                .merge(entity_class:)
            end

            it { expect(subject.entity_class).to be Grimoire }
          end

          context 'when initialized with qualified_name: value' do
            let(:qualified_name) { 'spec/scoped_books' }
            let(:constructor_options) do
              super().merge(qualified_name:)
            end
            let(:expected) do
              options[:default_entity_class] || Spec::ScopedBook
            end

            it { expect(subject.entity_class).to be expected }

            context 'when initialized with entity_class: value' do
              let(:entity_class) { Grimoire }
              let(:constructor_options) do
                super()
                  .tap { |hsh| hsh.delete(:name) }
                  .merge(entity_class:)
              end

              it { expect(subject.entity_class).to be Grimoire }
            end
          end
        end

        context 'when initialized with qualified_name: a String' do
          let(:qualified_name) { 'spec/scoped_books' }
          let(:constructor_options) do
            super().merge(qualified_name:)
          end
          let(:expected) do
            options[:default_entity_class] || Spec::ScopedBook
          end

          it { expect(subject.entity_class).to be expected }

          context 'when initialized with entity_class: value' do
            let(:entity_class) { Grimoire }
            let(:constructor_options) do
              super()
                .tap { |hsh| hsh.delete(:name) }
                .merge(entity_class:)
            end

            it { expect(subject.entity_class).to be Grimoire }
          end
        end

        context 'when initialized with qualified_name: a Symbol' do
          let(:qualified_name) { :'spec/scoped_books' }
          let(:constructor_options) do
            super().merge(qualified_name:)
          end
          let(:expected) do
            options[:default_entity_class] || Spec::ScopedBook
          end

          it { expect(subject.entity_class).to be expected }

          context 'when initialized with entity_class: value' do
            let(:entity_class) { Grimoire }
            let(:constructor_options) do
              super()
                .tap { |hsh| hsh.delete(:name) }
                .merge(entity_class:)
            end

            it { expect(subject.entity_class).to be Grimoire }
          end
        end
      end

      describe '#name' do
        include_examples 'should define reader', :name

        context 'when initialized with entity_class: a Class' do
          let(:entity_class) { Grimoire }
          let(:constructor_options) do
            super()
              .tap { |hsh| hsh.delete(:name) }
              .merge(entity_class:)
          end

          it { expect(subject.name).to be == 'grimoires' }

          context 'when initialized with name: value' do
            let(:name) { 'books' }
            let(:constructor_options) do
              super().merge(name:)
            end

            it { expect(subject.name).to be == name }
          end
        end

        context 'when initialized with entity_class: a scoped Class' do
          let(:entity_class) { Spec::ScopedBook }
          let(:constructor_options) do
            super()
              .tap { |hsh| hsh.delete(:name) }
              .merge(entity_class:)
          end

          it { expect(subject.name).to be == 'scoped_books' }

          context 'when initialized with name: value' do
            let(:name) { 'books' }
            let(:constructor_options) do
              super().merge(name:)
            end

            it { expect(subject.name).to be == name }
          end
        end

        context 'when initialized with entity_class: a String' do
          let(:entity_class) { 'Grimoire' }
          let(:constructor_options) do
            super()
              .tap { |hsh| hsh.delete(:name) }
              .merge(entity_class:)
          end

          it { expect(subject.name).to be == 'grimoires' }

          context 'when initialized with name: value' do
            let(:name) { 'books' }
            let(:constructor_options) do
              super().merge(name:)
            end

            it { expect(subject.name).to be == name }
          end
        end

        context 'when initialized with entity_class: a scoped String' do
          let(:entity_class) { 'Spec::ScopedBook' }
          let(:constructor_options) do
            super()
              .tap { |hsh| hsh.delete(:name) }
              .merge(entity_class:)
          end

          it { expect(subject.name).to be == 'scoped_books' }

          context 'when initialized with name: value' do
            let(:name) { 'books' }
            let(:constructor_options) do
              super().merge(name:)
            end

            it { expect(subject.name).to be == name }
          end
        end

        context 'when initialized with name: a String' do
          let(:name) { 'books' }
          let(:constructor_options) do
            super().merge(name:)
          end

          it { expect(subject.name).to be == name }
        end

        context 'when initialized with name: a Symbol' do
          let(:name) { :books }
          let(:constructor_options) do
            super().merge(name:)
          end

          it { expect(subject.name).to be == name.to_s }
        end
      end

      describe '#options' do
        include_examples 'should define reader', :options, -> { {} }

        context 'when initialized with entity_class: value' do
          let(:entity_class) { Grimoire }
          let(:constructor_options) do
            super()
              .tap { |hsh| hsh.delete(:name) }
              .merge(entity_class:)
          end

          it { expect(subject.options).to be == {} }
        end

        context 'when initialized with singular_name: value' do
          let(:singular_name) { 'book' }
          let(:constructor_options) do
            super().merge(singular_name:)
          end

          it { expect(subject.options).to be == {} }
        end

        context 'when initialized with name: value' do
          let(:name) { 'books' }
          let(:constructor_options) do
            super().merge(name:)
          end

          it { expect(subject.options).to be == {} }
        end

        context 'when initialized with qualified_name: value' do
          let(:qualified_name) { 'spec/scoped_books' }
          let(:constructor_options) do
            super().merge(qualified_name:)
          end

          it { expect(subject.options).to be == {} }
        end

        context 'when initialized with options' do
          let(:options) { { custom_option: 'custom value' } }
          let(:constructor_options) do
            super().merge(options)
          end

          it { expect(subject.options).to be == options }
        end
      end

      describe '#plural_name' do
        include_examples 'should define reader', :plural_name

        context 'when initialized with entity_class: a Class' do
          let(:entity_class) { Grimoire }
          let(:constructor_options) do
            super()
              .tap { |hsh| hsh.delete(:name) }
              .merge(entity_class:)
          end

          it { expect(subject.plural_name).to be == 'grimoires' }

          context 'when initialized with plural_name: value' do
            let(:plural_name) { 'books' }
            let(:constructor_options) do
              super().merge(plural_name:)
            end

            it { expect(subject.plural_name).to be == plural_name }
          end
        end

        context 'when initialized with entity_class: a scoped Class' do
          let(:entity_class) { Spec::ScopedBook }
          let(:constructor_options) do
            super()
              .tap { |hsh| hsh.delete(:name) }
              .merge(entity_class:)
          end

          it { expect(subject.plural_name).to be == 'scoped_books' }

          context 'when initialized with plural_name: value' do
            let(:plural_name) { 'books' }
            let(:constructor_options) do
              super().merge(plural_name:)
            end

            it { expect(subject.plural_name).to be == plural_name }
          end
        end

        context 'when initialized with entity_class: a String' do
          let(:entity_class) { 'Grimoire' }
          let(:constructor_options) do
            super()
              .tap { |hsh| hsh.delete(:name) }
              .merge(entity_class:)
          end

          it { expect(subject.plural_name).to be == 'grimoires' }

          context 'when initialized with plural_name: value' do
            let(:plural_name) { 'books' }
            let(:constructor_options) do
              super().merge(plural_name:)
            end

            it { expect(subject.plural_name).to be == plural_name }
          end
        end

        context 'when initialized with entity_class: a scoped String' do
          let(:entity_class) { 'Spec::ScopedBook' }
          let(:constructor_options) do
            super()
              .tap { |hsh| hsh.delete(:name) }
              .merge(entity_class:)
          end

          it { expect(subject.plural_name).to be == 'scoped_books' }

          context 'when initialized with plural_name: value' do
            let(:plural_name) { 'books' }
            let(:constructor_options) do
              super().merge(plural_name:)
            end

            it { expect(subject.plural_name).to be == plural_name }
          end
        end

        context 'when initialized with name: a String' do
          let(:name) { 'grimoires' }
          let(:constructor_options) do
            super().merge(name:)
          end

          it { expect(subject.plural_name).to be == 'grimoires' }

          context 'when initialized with plural_name: value' do
            let(:plural_name) { 'books' }
            let(:constructor_options) do
              super().merge(plural_name:)
            end

            it { expect(subject.plural_name).to be == plural_name }
          end
        end

        context 'when initialized with name: a Symbol' do
          let(:name) { :grimoires }
          let(:constructor_options) do
            super().merge(name:)
          end

          it { expect(subject.plural_name).to be == 'grimoires' }

          context 'when initialized with plural_name: value' do
            let(:plural_name) { 'books' }
            let(:constructor_options) do
              super().merge(plural_name:)
            end

            it { expect(subject.plural_name).to be == plural_name }
          end
        end
      end

      describe '#qualified_name' do
        include_examples 'should define reader', :qualified_name

        context 'when initialized with entity_class: a Class' do
          let(:entity_class) { Grimoire }
          let(:constructor_options) do
            super()
              .tap { |hsh| hsh.delete(:name) }
              .merge(entity_class:)
          end

          it { expect(subject.qualified_name).to be == 'grimoires' }

          context 'when initialized with qualified_name: value' do
            let(:qualified_name) { 'path/to/books' }
            let(:constructor_options) do
              super().merge(qualified_name:)
            end

            it { expect(subject.qualified_name).to be == qualified_name }
          end
        end

        context 'when initialized with entity_class: a scoped Class' do
          let(:entity_class) { Spec::ScopedBook }
          let(:constructor_options) do
            super()
              .tap { |hsh| hsh.delete(:name) }
              .merge(entity_class:)
          end

          it { expect(subject.qualified_name).to be == 'spec/scoped_books' }

          context 'when initialized with qualified_name: value' do
            let(:qualified_name) { 'path/to/books' }
            let(:constructor_options) do
              super().merge(qualified_name:)
            end

            it { expect(subject.qualified_name).to be == qualified_name }
          end
        end

        context 'when initialized with entity_class: a String' do
          let(:entity_class) { 'Grimoire' }
          let(:constructor_options) do
            super()
              .tap { |hsh| hsh.delete(:name) }
              .merge(entity_class:)
          end

          it { expect(subject.qualified_name).to be == 'grimoires' }

          context 'when initialized with qualified_name: value' do
            let(:qualified_name) { 'path/to/books' }
            let(:constructor_options) do
              super().merge(qualified_name:)
            end

            it { expect(subject.qualified_name).to be == qualified_name }
          end
        end

        context 'when initialized with entity_class: a scoped String' do
          let(:entity_class) { 'Spec::ScopedBook' }
          let(:constructor_options) do
            super()
              .tap { |hsh| hsh.delete(:name) }
              .merge(entity_class:)
          end

          it { expect(subject.qualified_name).to be == 'spec/scoped_books' }

          context 'when initialized with qualified_name: value' do
            let(:qualified_name) { 'path/to/books' }
            let(:constructor_options) do
              super().merge(qualified_name:)
            end

            it { expect(subject.qualified_name).to be == qualified_name }
          end
        end

        context 'when initialized with name: a String' do
          let(:name) { 'books' }
          let(:constructor_options) do
            super().merge(name:)
          end

          it { expect(subject.qualified_name).to be == name }

          context 'when initialized with qualified_name: value' do
            let(:qualified_name) { 'path/to/books' }
            let(:constructor_options) do
              super().merge(qualified_name:)
            end

            it { expect(subject.qualified_name).to be == qualified_name }
          end
        end

        context 'when initialized with name: a Symbol' do
          let(:name) { :books }
          let(:constructor_options) do
            super().merge(name:)
          end

          it { expect(subject.qualified_name).to be == name.to_s }

          context 'when initialized with qualified_name: value' do
            let(:qualified_name) { 'path/to/books' }
            let(:constructor_options) do
              super().merge(qualified_name:)
            end

            it { expect(subject.qualified_name).to be == qualified_name }
          end
        end

        context 'when initialized with qualified_name: a String' do
          let(:qualified_name) { 'path/to/books' }
          let(:constructor_options) do
            super().merge(qualified_name:)
          end

          it { expect(subject.qualified_name).to be == qualified_name }
        end

        context 'when initialized with qualified_name: a Symbol' do
          let(:qualified_name) { :'path/to/books' }
          let(:constructor_options) do
            super().merge(qualified_name:)
          end

          it { expect(subject.qualified_name).to be == qualified_name.to_s }
        end
      end

      describe '#singular_name' do
        include_examples 'should define reader', :singular_name

        context 'when initialized with entity_class: a Class' do
          let(:entity_class) { Grimoire }
          let(:constructor_options) do
            super()
              .tap { |hsh| hsh.delete(:name) }
              .merge(entity_class:)
          end

          it { expect(subject.singular_name).to be == 'grimoire' }

          context 'when initialized with singular_name: value' do
            let(:singular_name) { 'book' }
            let(:constructor_options) do
              super().merge(singular_name:)
            end

            it { expect(subject.singular_name).to be == singular_name }
          end
        end

        context 'when initialized with entity_class: a scoped Class' do
          let(:entity_class) { Spec::ScopedBook }
          let(:constructor_options) do
            super()
              .tap { |hsh| hsh.delete(:name) }
              .merge(entity_class:)
          end

          it { expect(subject.singular_name).to be == 'scoped_book' }

          context 'when initialized with singular_name: value' do
            let(:singular_name) { 'book' }
            let(:constructor_options) do
              super().merge(singular_name:)
            end

            it { expect(subject.singular_name).to be == singular_name }
          end
        end

        context 'when initialized with entity_class: a String' do
          let(:entity_class) { 'Grimoire' }
          let(:constructor_options) do
            super()
              .tap { |hsh| hsh.delete(:name) }
              .merge(entity_class:)
          end

          it { expect(subject.singular_name).to be == 'grimoire' }

          context 'when initialized with singular_name: value' do
            let(:singular_name) { 'book' }
            let(:constructor_options) do
              super().merge(singular_name:)
            end

            it { expect(subject.singular_name).to be == singular_name }
          end
        end

        context 'when initialized with entity_class: a scoped String' do
          let(:entity_class) { 'Spec::ScopedBook' }
          let(:constructor_options) do
            super()
              .tap { |hsh| hsh.delete(:name) }
              .merge(entity_class:)
          end

          it { expect(subject.singular_name).to be == 'scoped_book' }

          context 'when initialized with singular_name: value' do
            let(:singular_name) { 'book' }
            let(:constructor_options) do
              super().merge(singular_name:)
            end

            it { expect(subject.singular_name).to be == singular_name }
          end
        end

        context 'when initialized with name: a String' do
          let(:name) { 'grimoires' }
          let(:constructor_options) do
            super().merge(name:)
          end

          it { expect(subject.singular_name).to be == 'grimoire' }

          context 'when initialized with singular_name: value' do
            let(:singular_name) { 'book' }
            let(:constructor_options) do
              super().merge(singular_name:)
            end

            it { expect(subject.singular_name).to be == singular_name }
          end
        end

        context 'when initialized with name: a Symbol' do
          let(:name) { :grimoires }
          let(:constructor_options) do
            super().merge(name:)
          end

          it { expect(subject.singular_name).to be == 'grimoire' }

          context 'when initialized with singular_name: value' do
            let(:singular_name) { 'book' }
            let(:constructor_options) do
              super().merge(singular_name:)
            end

            it { expect(subject.singular_name).to be == singular_name }
          end
        end
      end
    end

    deferred_examples 'should define Relation cardinality' do
      describe '.new' do
        describe 'with plural: an Object' do
          let(:constructor_options) do
            super().merge(plural: Object.new.freeze)
          end
          let(:error_message) do
            'plural must be true or false'
          end

          it 'should raise an exception' do
            expect { described_class.new(**constructor_options) }
              .to raise_error ArgumentError, error_message
          end
        end

        describe 'with singular: an Object' do
          let(:constructor_options) do
            super().merge(singular: Object.new.freeze)
          end
          let(:error_message) do
            'singular must be true or false'
          end

          it 'should raise an exception' do
            expect { described_class.new(**constructor_options) }
              .to raise_error ArgumentError, error_message
          end
        end

        describe 'with singular: nil and plural: value' do
          let(:constructor_options) do
            super().merge(plural: true, singular: nil)
          end

          it 'should not raise an exception' do
            expect { described_class.new(**constructor_options) }
              .not_to raise_error
          end
        end

        describe 'with singular: value and plural: nil' do
          let(:constructor_options) do
            super().merge(plural: nil, singular: true)
          end

          it 'should not raise an exception' do
            expect { described_class.new(**constructor_options) }
              .not_to raise_error
          end
        end

        describe 'with singular: value and plural: value' do
          let(:constructor_options) do
            super().merge(singular: true, plural: false)
          end
          let(:error_message) do
            'ambiguous cardinality: initialized with parameters ' \
              'plural: false and singular: true'
          end

          it 'should raise an exception' do
            expect { described_class.new(**constructor_options) }
              .to raise_error ArgumentError, error_message
          end
        end
      end

      describe '#plural?' do
        include_examples 'should define predicate', :plural?, true

        context 'when initialized with plural: false' do
          let(:constructor_options) { super().merge(plural: false) }

          it { expect(subject.plural?).to be false }
        end

        context 'when initialized with plural: true' do
          let(:constructor_options) { super().merge(plural: true) }

          it { expect(subject.plural?).to be true }
        end

        context 'when initialized with singular: false' do
          let(:constructor_options) { super().merge(singular: false) }

          it { expect(subject.plural?).to be true }
        end

        context 'when initialized with singular: true' do
          let(:constructor_options) { super().merge(singular: true) }

          it { expect(subject.plural?).to be false }
        end
      end

      describe '#singular?' do
        include_examples 'should define predicate', :singular?, false

        context 'when initialized with plural: false' do
          let(:constructor_options) { super().merge(plural: false) }

          it { expect(subject.singular?).to be true }
        end

        context 'when initialized with plural: true' do
          let(:constructor_options) { super().merge(plural: true) }

          it { expect(subject.singular?).to be false }
        end

        context 'when initialized with singular: false' do
          let(:constructor_options) { super().merge(singular: false) }

          it { expect(subject.singular?).to be false }
        end

        context 'when initialized with singular: true' do
          let(:constructor_options) { super().merge(singular: true) }

          it { expect(subject.singular?).to be true }
        end
      end
    end

    deferred_examples 'should define Relation primary key' do
      describe '#primary_key_name' do
        let(:expected_primary_key_name) do
          return super() if defined?(super())

          constructor_options.fetch(:primary_key_name, 'id')
        end

        include_examples 'should define reader',
          :primary_key_name,
          -> { expected_primary_key_name }

        context 'when initialized with primary_key_name: a String' do
          let(:primary_key_name) { 'uuid' }
          let(:constructor_options) do
            super().merge(primary_key_name:)
          end

          it { expect(subject.primary_key_name).to be == primary_key_name }
        end

        context 'when initialized with primary_key_name: a Symbol' do
          let(:primary_key_name) { :uuid }
          let(:constructor_options) do
            super().merge(primary_key_name:)
          end

          it 'should set the primary key name' do
            expect(subject.primary_key_name).to be == primary_key_name.to_s
          end
        end
      end

      describe '#primary_key_type' do
        let(:expected_primary_key_type) do
          return super() if defined?(super())

          constructor_options.fetch(:primary_key_type, Integer)
        end

        include_examples 'should define reader',
          :primary_key_type,
          -> { expected_primary_key_type }

        context 'when initialized with primary_key_type: value' do
          let(:primary_key_type) { String }
          let(:constructor_options) do
            super().merge(primary_key_type:)
          end

          it { expect(subject.primary_key_type).to be == primary_key_type }
        end
      end
    end

    deferred_examples 'should validate the Relation parameters' do
      describe 'with no parameters' do
        let(:error_message) { "name or entity class can't be blank" }

        it 'should raise an exception' do
          expect { call_method }
            .to raise_error ArgumentError, error_message
        end
      end

      describe 'with entity_class: nil' do
        let(:error_message) { "name or entity class can't be blank" }

        it 'should raise an exception' do
          expect { call_method(entity_class: nil) }
            .to raise_error ArgumentError, error_message
        end
      end

      describe 'with entity_class: an Object' do
        let(:error_message) do
          'entity class is not a Class, a String or a Symbol'
        end

        it 'should raise an exception' do
          expect do
            call_method(entity_class: Object.new.freeze)
          end
            .to raise_error ArgumentError, error_message
        end
      end

      describe 'with entity_class: an empty String' do
        let(:error_message) { "entity class can't be blank" }

        it 'should raise an exception' do
          expect { call_method(entity_class: '') }
            .to raise_error ArgumentError, error_message
        end
      end

      describe 'with entity_class: an empty Symbol' do
        let(:error_message) { "entity class can't be blank" }

        it 'should raise an exception' do
          expect { call_method(entity_class: :'') }
            .to raise_error ArgumentError, error_message
        end
      end

      describe 'with name: nil' do
        let(:error_message) { "name or entity class can't be blank" }

        it 'should raise an exception' do
          expect { call_method(name: nil) }
            .to raise_error ArgumentError, error_message
        end
      end

      describe 'with name: nil and entity_class: value' do
        it 'should not raise an exception' do
          expect do
            call_method(entity_class: 'Book', name: nil)
          end
            .not_to raise_error
        end
      end

      describe 'with name: an Object' do
        let(:error_message) { 'name is not a String or a Symbol' }

        it 'should raise an exception' do
          expect { call_method(name: Object.new.freeze) }
            .to raise_error ArgumentError, error_message
        end
      end

      describe 'with name: an empty String' do
        let(:error_message) { "name can't be blank" }

        it 'should raise an exception' do
          expect { call_method(name: '') }
            .to raise_error ArgumentError, error_message
        end
      end

      describe 'with name: an empty Symbol' do
        let(:error_message) { "name can't be blank" }

        it 'should raise an exception' do
          expect { call_method(name: '') }
            .to raise_error ArgumentError, error_message
        end
      end

      describe 'with name: value and entity_class: nil' do
        it 'should not raise an exception' do
          expect do
            call_method(entity_class: 'Book', name: nil)
          end
            .not_to raise_error
        end
      end

      describe 'with name: value and entity_class: an Object' do
        let(:error_message) do
          'entity class is not a Class, a String or a Symbol'
        end

        it 'should raise an exception' do
          expect do
            call_method(
              entity_class: Object.new.freeze,
              name:         'books'
            )
          end
            .to raise_error ArgumentError, error_message
        end
      end

      describe 'with name: value and entity_class: an empty String' do
        let(:error_message) { "entity class can't be blank" }

        it 'should raise an exception' do
          expect { call_method(entity_class: '', name: 'books') }
            .to raise_error ArgumentError, error_message
        end
      end

      describe 'with name: value and entity_class: an empty Symbol' do
        let(:error_message) { "entity class can't be blank" }

        it 'should raise an exception' do
          expect { call_method(entity_class: :'', name: 'books') }
            .to raise_error ArgumentError, error_message
        end
      end

      describe 'with plural_name: an Object' do
        let(:error_message) { 'plural name is not a String or a Symbol' }

        it 'should raise an exception' do
          expect do
            call_method(
              name:        'books',
              plural_name: Object.new.freeze
            )
          end
            .to raise_error ArgumentError, error_message
        end
      end

      describe 'with plural_name: an empty String' do
        let(:error_message) { "plural name can't be blank" }

        it 'should raise an exception' do
          expect do
            call_method(
              name:        'books',
              plural_name: ''
            )
          end
            .to raise_error ArgumentError, error_message
        end
      end

      describe 'with plural_name: an empty Symbol' do
        let(:error_message) { "plural name can't be blank" }

        it 'should raise an exception' do
          expect do
            call_method(
              name:        'books',
              plural_name: :''
            )
          end
            .to raise_error ArgumentError, error_message
        end
      end

      describe 'with qualified_name: an Object' do
        let(:error_message) { 'qualified name is not a String or a Symbol' }

        it 'should raise an exception' do
          expect do
            call_method(
              name:           'books',
              qualified_name: Object.new.freeze
            )
          end
            .to raise_error ArgumentError, error_message
        end
      end

      describe 'with qualified_name: an empty String' do
        let(:error_message) { "qualified name can't be blank" }

        it 'should raise an exception' do
          expect do
            call_method(
              name:           'books',
              qualified_name: ''
            )
          end
            .to raise_error ArgumentError, error_message
        end
      end

      describe 'with qualified_name: an empty Symbol' do
        let(:error_message) { "qualified name can't be blank" }

        it 'should raise an exception' do
          expect do
            call_method(
              name:           'books',
              qualified_name: :''
            )
          end
            .to raise_error ArgumentError, error_message
        end
      end

      describe 'with qualified_name: value and name, entity_class: nil' do
        it 'should not raise an exception' do
          expect do
            call_method(entity_class: nil, name: nil, qualified_name: 'books')
          end
            .not_to raise_error
        end
      end

      describe 'with singular_name: an Object' do
        let(:error_message) { 'singular name is not a String or a Symbol' }

        it 'should raise an exception' do
          expect do
            call_method(
              name:          'books',
              singular_name: Object.new.freeze
            )
          end
            .to raise_error ArgumentError, error_message
        end
      end

      describe 'with singular_name: an empty String' do
        let(:error_message) { "singular name can't be blank" }

        it 'should raise an exception' do
          expect do
            call_method(
              name:          'books',
              singular_name: ''
            )
          end
            .to raise_error ArgumentError, error_message
        end
      end

      describe 'with singular_name: an empty Symbol' do
        let(:error_message) { "singular name can't be blank" }

        it 'should raise an exception' do
          expect do
            call_method(
              name:          'books',
              singular_name: :''
            )
          end
            .to raise_error ArgumentError, error_message
        end
      end
    end
  end
end
