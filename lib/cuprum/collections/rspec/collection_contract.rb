# frozen_string_literal: true

require 'rspec/sleeping_king_studios/contract'

require 'cuprum/collections/rspec'
require 'cuprum/collections/rspec/contracts/relation_contracts'

module Cuprum::Collections::RSpec
  # Contract validating the behavior of a Collection.
  module CollectionContract
    extend RSpec::SleepingKingStudios::Contract

    # @!method apply(example_group)
    #   Adds the contract to the example group.
    #
    #   @param example_group [RSpec::Core::ExampleGroup] The example group to
    #     which the contract is applied.
    #   @param options [Hash] additional options for the contract.
    #
    #   @option options abstract [Boolean] if true, the collection is an
    #     abstract base class and does not define a query or commands.
    #   @option options default_entity_class [Class] the default entity class
    #     for the collection, if any.

    contract do |**options|
      include Cuprum::Collections::RSpec::Contracts::RelationContracts

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

          it { expect(collection).to define_constant(class_name) }

          it { expect(collection.const_get(class_name)).to be_a Class }

          it { expect(collection.const_get(class_name)).to be < command_class }

          it { expect(command.options).to be >= {} }

          command_options.each do |option_name|
            it "should set the ##{option_name}" do
              expect(command.send(option_name))
                .to be == collection.send(option_name)
            end
          end

          describe 'with options' do
            let(:constructor_options) do
              super().merge(
                custom_option: 'value',
                member_name:   'tome'
              )
            end

            it { expect(command.options).to be >= { custom_option: 'value' } }

            command_options.each do |option_name|
              it "should set the ##{option_name}" do
                expect(command.send(option_name)).to(
                  be == constructor_options.fetch(option_name) do
                    collection.send(option_name)
                  end
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
                .to be == collection.send(option_name)
            end
          end

          describe 'with options' do
            let(:constructor_options) do
              super().merge(
                custom_option: 'value',
                member_name:   'tome'
              )
            end

            it { expect(command.options).to be >= { custom_option: 'value' } }

            command_options.each do |option_name|
              it "should set the ##{option_name}" do
                expect(command.send(option_name)).to(
                  be == constructor_options.fetch(option_name) do
                    collection.send(option_name)
                  end
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
        let(:other_options)    { { collection_name: name } }
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

          example_class 'Spec::OtherCollection', Cuprum::Collections::Collection

          it { expect(collection == other_collection).to be false }
        end

        context 'when initialized with options' do
          let(:constructor_options) do
            super().merge(
              member_name:    'grimoire',
              qualified_name: 'spec/scoped_books'
            )
          end

          describe 'with a collection with non-matching properties' do
            it { expect(collection == other_collection).to be false }
          end

          describe 'with a collection with matching properties' do
            let(:other_options) do
              super().merge(
                member_name:    'grimoire',
                qualified_name: 'spec/scoped_books'
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
        it 'should define the method' do
          expect(collection)
            .to respond_to(:matches?)
            .with(0).arguments
            .and_any_keywords
        end

        describe 'with no options' do
          it { expect(collection.matches?).to be true }
        end

        describe 'with non-matching options' do
          let(:other_options) { { collection_name: 'spec/scoped_books' } }

          it { expect(collection.matches?(**other_options)).to be false }
        end

        describe 'with partially-matching options' do
          let(:other_options) do
            {
              collection_name: name,
              member_name:     'grimoire'
            }
          end

          it { expect(collection.matches?(**other_options)).to be false }
        end

        describe 'with matching options' do
          let(:other_options) { { collection_name: name } }

          it { expect(collection.matches?(**other_options)).to be true }
        end
      end

      describe '#primary_key_name' do
        let(:expected_primary_key_name) do
          return super() if defined?(super())

          options.fetch(:primary_key_name, 'id')
        end

        include_examples 'should define reader',
          :primary_key_name,
          -> { expected_primary_key_name }

        context 'when initialized with primary_key_name: a String' do
          let(:primary_key_name) { 'uuid' }
          let(:constructor_options) do
            super().merge(primary_key_name: primary_key_name)
          end

          it { expect(collection.primary_key_name).to be == primary_key_name }
        end

        context 'when initialized with primary_key_name: a Symbol' do
          let(:primary_key_name) { :uuid }
          let(:constructor_options) do
            super().merge(primary_key_name: primary_key_name)
          end

          it 'should set the primary key name' do
            expect(collection.primary_key_name).to be == primary_key_name.to_s
          end
        end
      end

      describe '#primary_key_type' do
        let(:expected_primary_key_type) do
          return super() if defined?(super())

          options.fetch(:primary_key_type, Integer)
        end

        include_examples 'should define reader',
          :primary_key_type,
          -> { expected_primary_key_type }

        context 'when initialized with primary_key_type: value' do
          let(:primary_key_type) { String }
          let(:constructor_options) do
            super().merge(primary_key_type: primary_key_type)
          end

          it { expect(collection.primary_key_type).to be == primary_key_type }
        end
      end

      describe '#query' do
        let(:error_message) do
          "#{described_class.name} is an abstract class. Define a repository " \
            'subclass and implement the #query method.'
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
              expect(collection.query.send option).to be == value
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
