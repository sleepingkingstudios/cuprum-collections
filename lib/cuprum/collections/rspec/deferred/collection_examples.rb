# frozen_string_literal: true

require 'rspec/sleeping_king_studios/deferred'

require 'cuprum/collections/rspec/deferred'
require 'cuprum/collections/rspec/deferred/relation_examples'

module Cuprum::Collections::RSpec::Deferred
  # Deferred examples for testing collections.
  module CollectionExamples
    include RSpec::SleepingKingStudios::Deferred::Provider
    include Cuprum::Collections::RSpec::Deferred::RelationExamples

    deferred_examples 'should be a Collection' do |**options|
      include Cuprum::Collections::RSpec::Deferred::RelationExamples

      deferred_examples 'should define the command' \
      do |command_name, command_class_name = nil|
        next if options[:abstract]

        tools      = SleepingKingStudios::Tools::Toolbelt.instance
        class_name = tools.str.camelize(command_name)

        describe "##{command_name}" do
          let(:constructor_options) { defined?(super()) ? super() : {} }
          let(:command)             { build_command(collection) }
          let(:command_class) do
            (
              command_class_name ||
              "#{options[:commands_namespace]}::#{class_name}"
            )
              .then { |str| Object.const_get(str) }
          end

          define_method(:build_command) do |collection|
            collection.send(command_name, **constructor_options)
          end

          it 'should define the command' do
            expect(collection)
              .to respond_to(command_name)
              .with(0).arguments
              .and_any_keywords
          end

          it { expect(command).to be_a command_class }

          it { expect(command.collection).to be subject }
        end
      end

      include_deferred 'should be a Relation',
        constructor:          false,
        default_entity_class: options[:default_entity_class]

      include_deferred 'should define Relation primary key'

      include_deferred 'should define Relation scope',
        default_scope: options[:default_scope]

      include_deferred 'should define the command', :assign_one

      include_deferred 'should define the command', :build_one

      include_deferred 'should define the command', :destroy_one

      include_deferred 'should define the command', :find_many

      include_deferred 'should define the command', :find_matching

      include_deferred 'should define the command', :find_one

      include_deferred 'should define the command', :insert_one

      include_deferred 'should define the command', :update_one

      include_deferred 'should define the command', :validate_one

      describe '#==' do
        let(:other_options) do
          next super() if defined?(super())

          { name: }
        end
        let(:other_collection) { described_class.new(**other_options) }

        describe 'with nil' do
          it { expect(collection == nil).to be false } # rubocop:disable Style/NilComparison
        end

        describe 'with an object' do
          it { expect(collection == Object.new.freeze).to be false }
        end

        describe 'with a collection with non-matching properties' do
          let(:other_options) { super().merge(custom_option: 'value') }

          it { expect(collection == other_collection).to be false }
        end

        describe 'with a collection with matching properties' do
          it { expect(collection == other_collection).to be true }
        end

        describe 'with another type of collection' do
          let(:other_collection) do
            Spec::OtherCollection.new(**other_options)
          end

          example_class 'Spec::OtherCollection',
            Cuprum::Collections::Collection

          it { expect(collection == other_collection).to be false }
        end

        context 'when initialized with options' do
          let(:constructor_options) do
            super().merge(
              qualified_name: 'spec/scoped_books',
              singular_name:  'grimoire'
            )
          end

          describe 'with a collection with non-matching properties' do
            it { expect(collection == other_collection).to be false }
          end

          describe 'with a collection with matching properties' do
            let(:other_options) do
              super().merge(
                qualified_name: 'spec/scoped_books',
                singular_name:  'grimoire'
              )
            end

            it { expect(collection == other_collection).to be true }
          end
        end
      end

      describe '#count' do
        it { expect(collection).to respond_to(:count).with(0).arguments }

        it { expect(collection).to have_aliased_method(:count).as(:size) }

        next if options[:abstract]

        it { expect(collection.count).to be 0 }

        wrap_context 'when the collection has many items' do
          it { expect(collection.count).to be items.count }
        end
      end

      describe '#matches?' do
        def tools
          SleepingKingStudios::Tools::Toolbelt.instance
        end

        it 'should define the method' do
          expect(collection)
            .to respond_to(:matches?)
            .with(0).arguments
            .and_any_keywords
        end

        describe 'with no options' do
          it { expect(collection.matches?).to be true }
        end

        describe 'with non-matching entity class as a Class' do
          let(:other_options) { { entity_class: Grimoire } }

          it { expect(collection.matches?(**other_options)).to be false }
        end

        describe 'with non-matching entity class as a String' do
          let(:other_options) { { entity_class: 'Grimoire' } }

          it { expect(collection.matches?(**other_options)).to be false }
        end

        describe 'with non-matching name' do
          it { expect(collection.matches?(name: 'grimoires')).to be false }
        end

        describe 'with non-matching primary key name' do
          let(:other_options) { { primary_key_name: 'uuid' } }

          it { expect(collection.matches?(**other_options)).to be false }
        end

        describe 'with non-matching primary key type' do
          let(:other_options) { { primary_key_type: String } }

          it { expect(collection.matches?(**other_options)).to be false }
        end

        describe 'with non-matching qualified name' do
          let(:other_options) { { qualified_name: 'spec/scoped_books' } }

          it { expect(collection.matches?(**other_options)).to be false }
        end

        describe 'with non-matching singular name' do
          let(:other_options) { { singular_name: 'grimoire' } }

          it { expect(collection.matches?(**other_options)).to be false }
        end

        describe 'with non-matching custom options' do
          let(:other_options) { { custom_option: 'custom value' } }

          it { expect(collection.matches?(**other_options)).to be false }
        end

        describe 'with partially-matching options' do
          let(:other_options) do
            {
              name:,
              singular_name: 'grimoire'
            }
          end

          it { expect(collection.matches?(**other_options)).to be false }
        end

        describe 'with matching entity class as a Class' do
          let(:configured_entity_class) do
            value = options.fetch(:default_entity_class, Book)
            value = instance_exec(&value) if value.is_a?(Proc)
            value
          end
          let(:other_options) { { entity_class: configured_entity_class } }

          it { expect(collection.matches?(**other_options)).to be true }
        end

        describe 'with matching entity class as a String' do
          let(:configured_entity_class) do
            value = options.fetch(:default_entity_class, Book)
            value = instance_exec(&value) if value.is_a?(Proc)
            value
          end
          let(:other_options) do
            { entity_class: configured_entity_class.to_s }
          end

          it { expect(collection.matches?(**other_options)).to be true }
        end

        describe 'with matching name as a String' do
          let(:other_options) { { name: name.to_s } }

          it { expect(collection.matches?(**other_options)).to be true }
        end

        describe 'with matching name as a Symbol' do
          let(:other_options) { { name: name.intern } }

          it { expect(collection.matches?(**other_options)).to be true }
        end

        describe 'with matching primary key name' do
          let(:other_options) { { primary_key_name: 'id' } }

          it { expect(collection.matches?(**other_options)).to be true }
        end

        describe 'with matching primary key type' do
          let(:other_options) { { primary_key_type: Integer } }

          it { expect(collection.matches?(**other_options)).to be true }
        end

        describe 'with matching qualified name as a String' do
          let(:other_options) { { qualified_name: name.to_s } }

          it { expect(collection.matches?(**other_options)).to be true }
        end

        describe 'with matching qualified name as a Symbol' do
          let(:other_options) { { qualified_name: name.intern } }

          it { expect(collection.matches?(**other_options)).to be true }
        end

        describe 'with matching singular name' do
          let(:other_options) do
            { singular_name: tools.str.singularize(name) }
          end

          it { expect(collection.matches?(**other_options)).to be true }
        end

        describe 'with multiple matching options' do
          let(:other_options) do
            {
              name:,
              primary_key_name: 'id',
              qualified_name:   name
            }
          end

          it { expect(collection.matches?(**other_options)).to be true }
        end
      end

      describe '#query' do
        let(:error_message) do
          "#{described_class.name} is an abstract class. Define a " \
            'collection subclass and implement the #query method.'
        end
        let(:default_order) { defined?(super()) ? super() : {} }
        let(:query)         { collection.query }

        it { expect(collection).to respond_to(:query).with(0).arguments }

        if options[:abstract]
          it 'should raise an exception' do
            expect { collection.query }
              .to raise_error(
                described_class::AbstractCollectionError,
                error_message
              )
          end
        else
          it { expect(collection.query).to be_a query_class }

          it 'should set the query options' do
            query_options.each do |option, value|
              expect(collection.query.send(option)).to be == value
            end
          end

          it { expect(query.limit).to be nil }

          it { expect(query.offset).to be nil }

          it { expect(query.order).to be == default_order }

          it { expect(query.scope).to be == subject.scope }

          context 'when initialized with a scope' do
            let(:initial_scope) do
              Cuprum::Collections::Scope.new({ 'ok' => true })
            end
            let(:constructor_options) do
              super().merge(scope: initial_scope)
            end

            it { expect(query.scope).to be == subject.scope }
          end
        end
      end
    end
  end
end
