# frozen_string_literal: true

require 'cuprum/collections/rspec/contracts'
require 'cuprum/collections/rspec/contracts/relation_contracts'

module Cuprum::Collections::RSpec::Contracts
  # Contracts for asserting on Collection objects.
  module CollectionContracts
    include Cuprum::Collections::RSpec::Contracts::RelationContracts

    # Contract validating the behavior of a Collection.
    module ShouldBeACollectionContract
      extend RSpec::SleepingKingStudios::Contract

      # @!method apply(example_group, **options)
      #   Adds the contract to the example group.
      #
      #   @param example_group [RSpec::Core::ExampleGroup] the example group to
      #     which the contract is applied.
      #   @param options [Hash] additional options for the contract.
      #
      #   @option options abstract [Boolean] if true, the collection is an
      #     abstract base class and does not define a query or commands.
      #   @option options default_entity_class [Class] the default entity class
      #     for the collection, if any.

      contract do |**options|
        shared_examples 'should define the command' \
        do |command_name, command_class_name = nil|
          next if options[:abstract]

          tools           = SleepingKingStudios::Tools::Toolbelt.instance
          class_name      = tools.str.camelize(command_name)
          command_options = %i[
            collection_name
            member_name
            primary_key_name
            primary_key_type
          ] + options.fetch(:command_options, []).map(&:intern)

          describe "::#{class_name}" do
            let(:constructor_options) { defined?(super()) ? super() : {} }
            let(:command_class) do
              command_class_name ||
                "#{options[:commands_namespace]}::#{class_name}"
                  .then { |str| Object.const_get(str) }
            end
            let(:command) do
              collection.const_get(class_name).new(**constructor_options)
            end
            let(:expected_options) do
              Hash
                .new { |_, key| collection.send(key) }
                .merge(
                  collection_name: collection.name,
                  member_name:     collection.singular_name
                )
            end

            it { expect(collection).to define_constant(class_name) }

            it { expect(collection.const_get(class_name)).to be_a Class }

            it 'should be an instance of the command class' do
              expect(collection.const_get(class_name)).to be < command_class
            end

            it { expect(command.options).to be >= {} }

            command_options.each do |option_name|
              it "should set the ##{option_name}" do
                expect(command.send(option_name))
                  .to be == expected_options[option_name]
              end
            end

            describe 'with options' do
              let(:constructor_options) do
                super().merge(
                  custom_option: 'value',
                  singular_name: 'tome'
                )
              end

              it { expect(command.options).to be >= { custom_option: 'value' } }

              command_options.each do |option_name|
                it "should set the ##{option_name}" do
                  expect(command.send(option_name)).to(
                    be == expected_options[option_name]
                  )
                end
              end
            end
          end

          describe "##{command_name}" do
            let(:constructor_options) { defined?(super()) ? super() : {} }
            let(:command) do
              collection.send(command_name, **constructor_options)
            end
            let(:expected_options) do
              Hash
                .new { |_, key| collection.send(key) }
                .merge(
                  collection_name: collection.name,
                  member_name:     collection.singular_name
                )
            end

            it 'should define the command' do
              expect(collection)
                .to respond_to(command_name)
                .with(0).arguments
                .and_any_keywords
            end

            it { expect(command).to be_a collection.const_get(class_name) }

            command_options.each do |option_name|
              it "should set the ##{option_name}" do
                expect(command.send(option_name))
                  .to be == expected_options[option_name]
              end
            end

            describe 'with options' do
              let(:constructor_options) do
                super().merge(
                  custom_option: 'value',
                  singular_name: 'tome'
                )
              end

              it { expect(command.options).to be >= { custom_option: 'value' } }

              command_options.each do |option_name|
                it "should set the ##{option_name}" do
                  expect(command.send(option_name)).to(
                    be == expected_options[option_name]
                  )
                end
              end
            end
          end
        end

        include_contract 'should be a relation',
          constructor:          false,
          default_entity_class: options[:default_entity_class]

        include_contract 'should disambiguate parameter',
          :name,
          as: :collection_name

        include_contract 'should disambiguate parameter',
          :singular_name,
          as: :member_name

        include_contract 'should define primary keys'

        include_examples 'should define the command', :assign_one

        include_examples 'should define the command', :build_one

        include_examples 'should define the command', :destroy_one

        include_examples 'should define the command', :find_many

        include_examples 'should define the command', :find_matching

        include_examples 'should define the command', :find_one

        include_examples 'should define the command', :insert_one

        include_examples 'should define the command', :update_one

        include_examples 'should define the command', :validate_one

        describe '#==' do
          let(:other_options)    { { name: name } }
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
                name:          name,
                singular_name: 'grimoire'
              }
            end

            it { expect(collection.matches?(**other_options)).to be false }
          end

          describe 'with matching entity class as a Class' do
            let(:configured_entity_class) do
              options.fetch(:default_entity_class, Book)
            end
            let(:other_options) { { entity_class: configured_entity_class } }

            it { expect(collection.matches?(**other_options)).to be true }
          end

          describe 'with matching entity class as a String' do
            let(:configured_entity_class) do
              options.fetch(:default_entity_class, Book)
            end
            let(:other_options) do
              { entity_class: configured_entity_class.to_s }
            end

            it { expect(collection.matches?(**other_options)).to be true }
          end

          describe 'with matching name' do
            let(:other_options) { { collection_name: name } }

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

          describe 'with matching qualified name' do
            let(:other_options) { { qualified_name: name } }

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
                collection_name:  name,
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
              'repository subclass and implement the #query method.'
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

            it { expect(query.criteria).to be == [] }

            it { expect(query.limit).to be nil }

            it { expect(query.offset).to be nil }

            it { expect(query.order).to be == default_order }
          end
        end
      end
    end
  end
end
