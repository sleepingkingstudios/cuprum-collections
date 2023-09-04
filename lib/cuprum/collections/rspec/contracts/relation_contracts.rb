# frozen_string_literal: true

require 'cuprum/collections/rspec/contracts'

module Cuprum::Collections::RSpec::Contracts
  # Contracts for asserting on Relation objects.
  module RelationContracts
    # Contract asserting that the method validates the required parameters.
    module ShouldValidateTheParametersContract
      extend RSpec::SleepingKingStudios::Contract

      # @!method apply(example_group)
      #   Adds the contract to the example group.
      contract do
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

        describe 'with singular_name: an Object' do
          let(:error_message) { 'member name is not a String or a Symbol' }

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
          let(:error_message) { "member name can't be blank" }

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
          let(:error_message) { "member name can't be blank" }

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
      end
    end

    # Contract validating the behavior of a Relation.
    module ShouldBeARelationContract
      extend RSpec::SleepingKingStudios::Contract

      # @!method apply(example_group)
      #   Adds the contract to the example group.
      #
      #   @param options [Hash] additional options for the contract.
      #
      #   @option options cardinality [Boolean] true if the relation accepts
      #     cardinality keywords (:plural, :singular); otherwise false.
      #   @option options expected_keywords [Array<Symbol>] additional keywords
      #     for the constructor.
      contract do |**options|
        include Cuprum::Collections::RSpec::Contracts::RelationContracts

        describe '.new' do
          let(:expected_keywords) do
            keywords = %i[
              entity_class
              singular_name
              name
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

          include_contract 'should validate the parameters'
        end

        describe '#entity_class' do
          include_examples 'should define reader', :entity_class

          context 'when initialized with entity_class: a Class' do
            let(:entity_class) { Grimoire }
            let(:constructor_options) do
              super()
                .tap { |hsh| hsh.delete(:name) }
                .merge(entity_class: entity_class)
            end

            it { expect(subject.entity_class).to be Grimoire }
          end

          context 'when initialized with entity_class: a scoped Class' do
            let(:entity_class) { Spec::ScopedBook }
            let(:constructor_options) do
              super()
                .tap { |hsh| hsh.delete(:name) }
                .merge(entity_class: entity_class)
            end

            it { expect(subject.entity_class).to be Spec::ScopedBook }
          end

          context 'when initialized with entity_class: a String' do
            let(:entity_class) { 'Grimoire' }
            let(:constructor_options) do
              super()
                .tap { |hsh| hsh.delete(:name) }
                .merge(entity_class: entity_class)
            end

            it { expect(subject.entity_class).to be Grimoire }
          end

          context 'when initialized with entity_class: a scoped String' do
            let(:entity_class) { 'Spec::ScopedBook' }
            let(:constructor_options) do
              super()
                .tap { |hsh| hsh.delete(:name) }
                .merge(entity_class: entity_class)
            end

            it { expect(subject.entity_class).to be Spec::ScopedBook }
          end

          context 'when initialized with name: a String' do
            let(:name) { 'books' }
            let(:constructor_options) do
              super().merge(name: name)
            end

            it { expect(relation.entity_class).to be Book }

            context 'when initialized with entity_class: value' do
              let(:entity_class) { Grimoire }
              let(:constructor_options) do
                super()
                  .tap { |hsh| hsh.delete(:name) }
                  .merge(entity_class: entity_class)
              end

              it { expect(subject.entity_class).to be Grimoire }
            end

            context 'when initialized with qualified_name: value' do
              let(:qualified_name) { 'spec/scoped_books' }
              let(:constructor_options) do
                super().merge(qualified_name: qualified_name)
              end

              it { expect(subject.entity_class).to be Spec::ScopedBook }

              context 'when initialized with entity_class: value' do
                let(:entity_class) { Grimoire }
                let(:constructor_options) do
                  super()
                    .tap { |hsh| hsh.delete(:name) }
                    .merge(entity_class: entity_class)
                end

                it { expect(subject.entity_class).to be Grimoire }
              end
            end
          end

          context 'when initialized with name: a Symbol' do
            let(:name) { 'books' }
            let(:constructor_options) do
              super().merge(name: name)
            end

            it { expect(relation.entity_class).to be Book }

            context 'when initialized with entity_class: value' do
              let(:entity_class) { Grimoire }
              let(:constructor_options) do
                super()
                  .tap { |hsh| hsh.delete(:name) }
                  .merge(entity_class: entity_class)
              end

              it { expect(subject.entity_class).to be Grimoire }
            end

            context 'when initialized with qualified_name: value' do
              let(:qualified_name) { 'spec/scoped_books' }
              let(:constructor_options) do
                super().merge(qualified_name: qualified_name)
              end

              it { expect(subject.entity_class).to be Spec::ScopedBook }

              context 'when initialized with entity_class: value' do
                let(:entity_class) { Grimoire }
                let(:constructor_options) do
                  super()
                    .tap { |hsh| hsh.delete(:name) }
                    .merge(entity_class: entity_class)
                end

                it { expect(subject.entity_class).to be Grimoire }
              end
            end
          end

          context 'when initialized with qualified_name: a String' do
            let(:qualified_name) { 'spec/scoped_books' }
            let(:constructor_options) do
              super().merge(qualified_name: qualified_name)
            end

            it { expect(subject.entity_class).to be Spec::ScopedBook }

            context 'when initialized with entity_class: value' do
              let(:entity_class) { Grimoire }
              let(:constructor_options) do
                super()
                  .tap { |hsh| hsh.delete(:name) }
                  .merge(entity_class: entity_class)
              end

              it { expect(subject.entity_class).to be Grimoire }
            end
          end

          context 'when initialized with qualified_name: a Symbol' do
            let(:qualified_name) { :'spec/scoped_books' }
            let(:constructor_options) do
              super().merge(qualified_name: qualified_name)
            end

            it { expect(subject.entity_class).to be Spec::ScopedBook }

            context 'when initialized with entity_class: value' do
              let(:entity_class) { Grimoire }
              let(:constructor_options) do
                super()
                  .tap { |hsh| hsh.delete(:name) }
                  .merge(entity_class: entity_class)
              end

              it { expect(subject.entity_class).to be Grimoire }
            end
          end
        end

        describe '#singular_name' do
          include_examples 'should define reader', :singular_name

          context 'when initialized with entity_class: a Class' do
            let(:entity_class) { Grimoire }
            let(:constructor_options) do
              super()
                .tap { |hsh| hsh.delete(:name) }
                .merge(entity_class: entity_class)
            end

            it { expect(subject.singular_name).to be == 'grimoire' }

            context 'when initialized with singular_name: value' do
              let(:singular_name) { 'book' }
              let(:constructor_options) do
                super().merge(singular_name: singular_name)
              end

              it { expect(subject.singular_name).to be == singular_name }
            end
          end

          context 'when initialized with entity_class: a scoped Class' do
            let(:entity_class) { Spec::ScopedBook }
            let(:constructor_options) do
              super()
                .tap { |hsh| hsh.delete(:name) }
                .merge(entity_class: entity_class)
            end

            it { expect(subject.singular_name).to be == 'scoped_book' }

            context 'when initialized with singular_name: value' do
              let(:singular_name) { 'book' }
              let(:constructor_options) do
                super().merge(singular_name: singular_name)
              end

              it { expect(subject.singular_name).to be == singular_name }
            end
          end

          context 'when initialized with entity_class: a String' do
            let(:entity_class) { 'Grimoire' }
            let(:constructor_options) do
              super()
                .tap { |hsh| hsh.delete(:name) }
                .merge(entity_class: entity_class)
            end

            it { expect(subject.singular_name).to be == 'grimoire' }

            context 'when initialized with singular_name: value' do
              let(:singular_name) { 'book' }
              let(:constructor_options) do
                super().merge(singular_name: singular_name)
              end

              it { expect(subject.singular_name).to be == singular_name }
            end
          end

          context 'when initialized with entity_class: a scoped String' do
            let(:entity_class) { 'Spec::ScopedBook' }
            let(:constructor_options) do
              super()
                .tap { |hsh| hsh.delete(:name) }
                .merge(entity_class: entity_class)
            end

            it { expect(subject.singular_name).to be == 'scoped_book' }

            context 'when initialized with singular_name: value' do
              let(:singular_name) { 'book' }
              let(:constructor_options) do
                super().merge(singular_name: singular_name)
              end

              it { expect(subject.singular_name).to be == singular_name }
            end
          end

          context 'when initialized with singular_name: a String' do
            let(:singular_name) { 'book' }
            let(:constructor_options) do
              super().merge(singular_name: singular_name)
            end

            it { expect(subject.singular_name).to be == singular_name }
          end

          context 'when initialized with singular_name: a Symbol' do
            let(:singular_name) { :book }
            let(:constructor_options) do
              super().merge(singular_name: singular_name)
            end

            it { expect(subject.singular_name).to be == singular_name.to_s }
          end

          context 'when initialized with name: a String' do
            let(:name) { 'grimoires' }
            let(:constructor_options) do
              super().merge(name: name)
            end

            it { expect(subject.singular_name).to be == 'grimoire' }

            context 'when initialized with singular_name: value' do
              let(:singular_name) { 'book' }
              let(:constructor_options) do
                super().merge(singular_name: singular_name)
              end

              it { expect(subject.singular_name).to be == singular_name }
            end
          end

          context 'when initialized with name: a Symbol' do
            let(:name) { :grimoires }
            let(:constructor_options) do
              super().merge(name: name)
            end

            it { expect(subject.singular_name).to be == 'grimoire' }

            context 'when initialized with singular_name: value' do
              let(:singular_name) { 'book' }
              let(:constructor_options) do
                super().merge(singular_name: singular_name)
              end

              it { expect(subject.singular_name).to be == singular_name }
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
                .merge(entity_class: entity_class)
            end

            it { expect(subject.name).to be == 'grimoires' }

            context 'when initialized with name: value' do
              let(:name) { 'books' }
              let(:constructor_options) do
                super().merge(name: name)
              end

              it { expect(subject.name).to be == name }
            end
          end

          context 'when initialized with entity_class: a scoped Class' do
            let(:entity_class) { Spec::ScopedBook }
            let(:constructor_options) do
              super()
                .tap { |hsh| hsh.delete(:name) }
                .merge(entity_class: entity_class)
            end

            it { expect(subject.name).to be == 'scoped_books' }

            context 'when initialized with name: value' do
              let(:name) { 'books' }
              let(:constructor_options) do
                super().merge(name: name)
              end

              it { expect(subject.name).to be == name }
            end
          end

          context 'when initialized with entity_class: a String' do
            let(:entity_class) { 'Grimoire' }
            let(:constructor_options) do
              super()
                .tap { |hsh| hsh.delete(:name) }
                .merge(entity_class: entity_class)
            end

            it { expect(subject.name).to be == 'grimoires' }

            context 'when initialized with name: value' do
              let(:name) { 'books' }
              let(:constructor_options) do
                super().merge(name: name)
              end

              it { expect(subject.name).to be == name }
            end
          end

          context 'when initialized with entity_class: a scoped String' do
            let(:entity_class) { 'Spec::ScopedBook' }
            let(:constructor_options) do
              super()
                .tap { |hsh| hsh.delete(:name) }
                .merge(entity_class: entity_class)
            end

            it { expect(subject.name).to be == 'scoped_books' }

            context 'when initialized with name: value' do
              let(:name) { 'books' }
              let(:constructor_options) do
                super().merge(name: name)
              end

              it { expect(subject.name).to be == name }
            end
          end

          context 'when initialized with name: a String' do
            let(:name) { 'books' }
            let(:constructor_options) do
              super().merge(name: name)
            end

            it { expect(subject.name).to be == name }
          end

          context 'when initialized with name: a Symbol' do
            let(:name) { :books }
            let(:constructor_options) do
              super().merge(name: name)
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
                .merge(entity_class: entity_class)
            end

            it { expect(subject.options).to be == {} }
          end

          context 'when initialized with singular_name: value' do
            let(:singular_name) { 'book' }
            let(:constructor_options) do
              super().merge(singular_name: singular_name)
            end

            it { expect(subject.options).to be == {} }
          end

          context 'when initialized with name: value' do
            let(:name) { 'books' }
            let(:constructor_options) do
              super().merge(name: name)
            end

            it { expect(subject.options).to be == {} }
          end

          context 'when initialized with qualified_name: value' do
            let(:qualified_name) { 'spec/scoped_books' }
            let(:constructor_options) do
              super().merge(qualified_name: qualified_name)
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

        describe '#qualified_name' do
          include_examples 'should define reader', :qualified_name

          context 'when initialized with entity_class: a Class' do
            let(:entity_class) { Grimoire }
            let(:constructor_options) do
              super()
                .tap { |hsh| hsh.delete(:name) }
                .merge(entity_class: entity_class)
            end

            it { expect(subject.qualified_name).to be == 'grimoires' }

            context 'when initialized with qualified_name: value' do
              let(:qualified_name) { 'path/to/books' }
              let(:constructor_options) do
                super().merge(qualified_name: qualified_name)
              end

              it { expect(subject.qualified_name).to be == qualified_name }
            end
          end

          context 'when initialized with entity_class: a scoped Class' do
            let(:entity_class) { Spec::ScopedBook }
            let(:constructor_options) do
              super()
                .tap { |hsh| hsh.delete(:name) }
                .merge(entity_class: entity_class)
            end

            it { expect(subject.qualified_name).to be == 'spec/scoped_books' }

            context 'when initialized with qualified_name: value' do
              let(:qualified_name) { 'path/to/books' }
              let(:constructor_options) do
                super().merge(qualified_name: qualified_name)
              end

              it { expect(subject.qualified_name).to be == qualified_name }
            end
          end

          context 'when initialized with entity_class: a String' do
            let(:entity_class) { 'Grimoire' }
            let(:constructor_options) do
              super()
                .tap { |hsh| hsh.delete(:name) }
                .merge(entity_class: entity_class)
            end

            it { expect(subject.qualified_name).to be == 'grimoires' }

            context 'when initialized with qualified_name: value' do
              let(:qualified_name) { 'path/to/books' }
              let(:constructor_options) do
                super().merge(qualified_name: qualified_name)
              end

              it { expect(subject.qualified_name).to be == qualified_name }
            end
          end

          context 'when initialized with entity_class: a scoped String' do
            let(:entity_class) { 'Spec::ScopedBook' }
            let(:constructor_options) do
              super()
                .tap { |hsh| hsh.delete(:name) }
                .merge(entity_class: entity_class)
            end

            it { expect(subject.qualified_name).to be == 'spec/scoped_books' }

            context 'when initialized with qualified_name: value' do
              let(:qualified_name) { 'path/to/books' }
              let(:constructor_options) do
                super().merge(qualified_name: qualified_name)
              end

              it { expect(subject.qualified_name).to be == qualified_name }
            end
          end

          context 'when initialized with name: a String' do
            let(:name) { 'books' }
            let(:constructor_options) do
              super().merge(name: name)
            end

            it { expect(subject.qualified_name).to be == name }

            context 'when initialized with qualified_name: value' do
              let(:qualified_name) { 'path/to/books' }
              let(:constructor_options) do
                super().merge(qualified_name: qualified_name)
              end

              it { expect(subject.qualified_name).to be == qualified_name }
            end
          end

          context 'when initialized with name: a Symbol' do
            let(:name) { :books }
            let(:constructor_options) do
              super().merge(name: name)
            end

            it { expect(subject.qualified_name).to be == name.to_s }

            context 'when initialized with qualified_name: value' do
              let(:qualified_name) { 'path/to/books' }
              let(:constructor_options) do
                super().merge(qualified_name: qualified_name)
              end

              it { expect(subject.qualified_name).to be == qualified_name }
            end
          end

          context 'when initialized with qualified_name: a String' do
            let(:qualified_name) { 'path/to/books' }
            let(:constructor_options) do
              super().merge(qualified_name: qualified_name)
            end

            it { expect(subject.qualified_name).to be == qualified_name }
          end

          context 'when initialized with qualified_name: a Symbol' do
            let(:qualified_name) { :'path/to/books' }
            let(:constructor_options) do
              super().merge(qualified_name: qualified_name)
            end

            it { expect(subject.qualified_name).to be == qualified_name.to_s }
          end
        end
      end
    end
  end
end
