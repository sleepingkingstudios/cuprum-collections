# frozen_string_literal: true

require 'cuprum/collections/rspec/contracts'

module Cuprum::Collections::RSpec::Contracts
  # Contracts for asserting on Repository objects.
  #
  # @deprecated 0.6.0 Use RepositoryExamples instead.
  #   Note - requires defining a #build_collection(**options) helper method.
  module RepositoryContracts
    # Contract validating the behavior of a Repository.
    #
    # @deprecated 0.6.0
    module ShouldBeARepositoryContract
      extend RSpec::SleepingKingStudios::Contract

      # @!method apply(example_group, abstract:, **options)
      #   Adds the contract to the example group.
      #
      #   @param abstract [Boolean] if true, the repository is abstract and does
      #     not define certain methods. Defaults to false.
      #   @param example_group [RSpec::Core::ExampleGroup] the example group to
      #     which the contract is applied.
      #   @param options [Hash] additional options for the contract.
      #
      #   @option options collection_class [Class, String] the expected class
      #     for created collections.
      #   @option options entity_class [Class, String] the expected entity
      #     class.
      contract do |abstract: false, **options|
        SleepingKingStudios::Tools::Toolbelt
          .instance
          .core_tools
          .deprecate(
            'Cuprum::Collections::RSpec::Contracts::RepositoryContracts',
            message: 'Use RepositoryExamples instead.'
          )

        shared_examples 'should create the collection' do
          let(:configured_collection_class) do
            return super() if defined?(super())

            configured = options[:collection_class]

            # :nocov:
            if configured.is_a?(String)
              configured = Object.const_get(configured)
            end
            # :nocov:

            configured
          end
          let(:configured_entity_class) do
            return super() if defined?(super())

            # :nocov:
            expected =
              if collection_options.key?(:entity_class)
                collection_options[:entity_class]
              elsif options.key?(:entity_class)
                options[:entity_class]
              else
                qualified_name
                  .split('/')
                  .then { |ary| [*ary[0...-1], tools.str.singularize(ary[-1])] }
                  .map { |str| tools.str.camelize(str) }
                  .join('::')
              end
            # :nocov:
            expected = Object.const_get(expected) if expected.is_a?(String)

            expected
          end
          let(:configured_member_name) do
            return super() if defined?(super())

            tools.str.singularize(collection_name.to_s.split('/').last)
          end

          def tools
            SleepingKingStudios::Tools::Toolbelt.instance
          end

          it 'should create the collection' do
            create_collection(safe: false)

            expect(repository.key?(qualified_name)).to be true
          end

          it 'should return the collection' do
            collection = create_collection(safe: false)

            expect(collection).to be repository[qualified_name]
          end

          it { expect(collection).to be_a configured_collection_class }

          it 'should set the entity class' do
            expect(collection.entity_class).to be == configured_entity_class
          end

          it 'should set the collection name' do
            expect(collection.name).to be == collection_name.to_s
          end

          it 'should set the member name' do
            expect(collection.singular_name).to be == configured_member_name
          end

          it 'should set the qualified name' do
            expect(collection.qualified_name).to be == qualified_name
          end

          it 'should set the collection options' do
            expect(collection).to have_attributes(
              primary_key_name:,
              primary_key_type:
            )
          end
        end

        describe '#[]' do
          let(:error_class) do
            described_class::UndefinedCollectionError
          end
          let(:error_message) do
            "repository does not define collection #{collection_name.inspect}"
          end

          it { expect(repository).to respond_to(:[]).with(1).argument }

          describe 'with nil' do
            let(:collection_name) { nil }

            it 'should raise an exception' do
              expect { repository[collection_name] }
                .to raise_error(error_class, error_message)
            end
          end

          describe 'with an object' do
            let(:collection_name) { Object.new.freeze }

            it 'should raise an exception' do
              expect { repository[collection_name] }
                .to raise_error(error_class, error_message)
            end
          end

          describe 'with an invalid string' do
            let(:collection_name) { 'invalid_name' }

            it 'should raise an exception' do
              expect { repository[collection_name] }
                .to raise_error(error_class, error_message)
            end
          end

          describe 'with an invalid symbol' do
            let(:collection_name) { :invalid_name }

            it 'should raise an exception' do
              expect { repository[collection_name] }
                .to raise_error(error_class, error_message)
            end
          end

          wrap_context 'when the repository has many collections' do
            describe 'with an invalid string' do
              let(:collection_name) { 'invalid_name' }

              it 'should raise an exception' do
                expect { repository[collection_name] }
                  .to raise_error(error_class, error_message)
              end
            end

            describe 'with an invalid symbol' do
              let(:collection_name) { :invalid_name }

              it 'should raise an exception' do
                expect { repository[collection_name] }
                  .to raise_error(error_class, error_message)
              end
            end

            describe 'with a valid string' do
              let(:collection)      { collections.values.first }
              let(:collection_name) { collections.keys.first }

              it { expect(repository[collection_name]).to be collection }
            end

            describe 'with a valid symbol' do
              let(:collection)      { collections.values.first }
              let(:collection_name) { collections.keys.first.intern }

              it { expect(repository[collection_name]).to be collection }
            end
          end
        end

        describe '#add' do
          let(:error_class) do
            described_class::InvalidCollectionError
          end
          let(:error_message) do
            "#{collection.inspect} is not a valid collection"
          end

          it 'should define the method' do
            expect(repository)
              .to respond_to(:add)
              .with(1).argument
              .and_keywords(:force)
          end

          it 'should alias #add as #<<' do
            expect(repository.method(:<<)).to be == repository.method(:add)
          end

          describe 'with nil' do
            let(:collection) { nil }

            it 'should raise an exception' do
              expect { repository.add(collection) }
                .to raise_error(error_class, error_message)
            end
          end

          describe 'with an object' do
            let(:collection) { Object.new.freeze }

            it 'should raise an exception' do
              expect { repository.add(collection) }
                .to raise_error(error_class, error_message)
            end
          end

          describe 'with a collection' do
            it { expect(repository.add(example_collection)).to be repository }

            it 'should add the collection to the repository' do
              repository.add(example_collection)

              expect(repository[example_collection.qualified_name])
                .to be example_collection
            end

            describe 'with force: true' do
              it 'should add the collection to the repository' do
                repository.add(example_collection, force: true)

                expect(repository[example_collection.qualified_name])
                  .to be example_collection
              end
            end

            context 'when the collection already exists' do
              let(:error_message) do
                "collection #{example_collection.qualified_name} already exists"
              end

              before(:example) do
                allow(repository)
                  .to receive(:key?)
                  .with(example_collection.qualified_name)
                  .and_return(true)
              end

              it 'should raise an exception' do
                expect { repository.add(example_collection) }
                  .to raise_error(
                    described_class::DuplicateCollectionError,
                    error_message
                  )
              end

              it 'should not update the repository' do
                begin
                  repository.add(example_collection)
                rescue described_class::DuplicateCollectionError
                  # Do nothing.
                end

                expect { repository[example_collection.qualified_name] }
                  .to raise_error(
                    described_class::UndefinedCollectionError,
                    'repository does not define collection ' \
                    "#{example_collection.qualified_name.inspect}"
                  )
              end

              describe 'with force: true' do
                it 'should add the collection to the repository' do
                  repository.add(example_collection, force: true)

                  expect(repository[example_collection.qualified_name])
                    .to be example_collection
                end
              end
            end
          end
        end

        describe '#create' do
          let(:collection_name)    { 'books' }
          let(:qualified_name)     { collection_name.to_s }
          let(:primary_key_name)   { 'id' }
          let(:primary_key_type)   { Integer }
          let(:collection_options) { {} }
          let(:collection) do
            create_collection

            repository[qualified_name]
          end
          let(:error_message) do
            "#{described_class.name} is an abstract class. Define a " \
              'repository subclass and implement the #build_collection method.'
          end

          def create_collection(force: false, safe: true, **options)
            if safe
              begin
                repository.create(force:, **collection_options, **options)
              rescue StandardError
                # Do nothing.
              end
            else
              repository.create(force:, **collection_options, **options)
            end
          end

          it 'should define the method' do
            expect(repository)
              .to respond_to(:create)
              .with(0).arguments
              .and_keywords(:collection_name, :entity_class, :force)
              .and_any_keywords
          end

          if abstract
            it 'should raise an exception' do
              expect { create_collection(safe: false) }
                .to raise_error(
                  described_class::AbstractRepositoryError,
                  error_message
                )
            end

            next
          end

          describe 'with entity_class: a Class' do
            let(:entity_class) { Book }
            let(:collection_options) do
              super().merge(entity_class:)
            end

            include_examples 'should create the collection'
          end

          describe 'with entity_class: a String' do
            let(:entity_class) { 'Book' }
            let(:collection_options) do
              super().merge(entity_class:)
            end

            include_examples 'should create the collection'
          end

          describe 'with name: a String' do
            let(:collection_name) { 'books' }
            let(:collection_options) do
              super().merge(name: collection_name)
            end

            include_examples 'should create the collection'
          end

          describe 'with name: a Symbol' do
            let(:collection_name) { :books }
            let(:collection_options) do
              super().merge(name: collection_name)
            end

            include_examples 'should create the collection'
          end

          describe 'with collection options' do
            let(:primary_key_name) { 'uuid' }
            let(:primary_key_type) { String }
            let(:collection_options) do
              super().merge(
                name:             collection_name,
                primary_key_name:,
                primary_key_type:
              )
            end

            include_examples 'should create the collection'
          end

          context 'when the collection already exists' do
            let(:collection_name) { 'books' }
            let(:collection_options) do
              super().merge(name: collection_name)
            end
            let(:error_message) do
              "collection #{qualified_name} already exists"
            end

            before { create_collection(old: true) }

            it 'should raise an exception' do
              expect { create_collection(safe: false) }
                .to raise_error(
                  described_class::DuplicateCollectionError,
                  error_message
                )
            end

            it 'should not update the repository' do
              create_collection(old: false)

              collection = repository[qualified_name]

              expect(collection.options[:old]).to be true
            end

            describe 'with force: true' do
              it 'should update the repository' do
                create_collection(force: true, old: false)

                collection = repository[qualified_name]

                expect(collection.options[:old]).to be false
              end
            end
          end
        end

        describe '#find_or_create' do
          let(:collection_name)    { 'books' }
          let(:qualified_name)     { collection_name.to_s }
          let(:primary_key_name)   { 'id' }
          let(:primary_key_type)   { Integer }
          let(:collection_options) { {} }
          let(:collection) do
            create_collection

            repository[qualified_name]
          end
          let(:error_message) do
            "#{described_class.name} is an abstract class. Define a " \
              'repository subclass and implement the #build_collection method.'
          end

          before(:example) do
            allow(SleepingKingStudios::Tools::Toolbelt.instance.core_tools)
              .to receive(:deprecate)
          end

          def create_collection(safe: true, **options)
            if safe
              begin
                repository.find_or_create(**collection_options, **options)
              rescue StandardError
                # Do nothing.
              end
            else
              repository.find_or_create(**collection_options, **options)
            end
          end

          it 'should define the method' do
            expect(repository)
              .to respond_to(:find_or_create)
              .with(0).arguments
              .and_keywords(:entity_class)
              .and_any_keywords
          end

          if abstract
            let(:collection_options) { { name: collection_name } }

            it 'should raise an exception' do
              expect { create_collection(safe: false) }
                .to raise_error(
                  described_class::AbstractRepositoryError,
                  error_message
                )
            end

            next
          end

          describe 'with entity_class: a Class' do
            let(:entity_class) { Book }
            let(:collection_options) do
              super().merge(entity_class:)
            end

            include_examples 'should create the collection'
          end

          describe 'with entity_class: a String' do
            let(:entity_class) { Book }
            let(:collection_options) do
              super().merge(entity_class:)
            end

            include_examples 'should create the collection'
          end

          describe 'with name: a String' do
            let(:collection_name) { 'books' }
            let(:collection_options) do
              super().merge(name: collection_name)
            end

            include_examples 'should create the collection'
          end

          describe 'with name: a Symbol' do
            let(:collection_name) { :books }
            let(:collection_options) do
              super().merge(name: collection_name)
            end

            include_examples 'should create the collection'
          end

          describe 'with collection options' do
            let(:primary_key_name) { 'uuid' }
            let(:primary_key_type) { String }
            let(:qualified_name)   { 'spec/scoped_books' }
            let(:collection_options) do
              super().merge(
                name:             collection_name,
                primary_key_name:,
                primary_key_type:,
                qualified_name:
              )
            end

            include_examples 'should create the collection'
          end

          context 'when the collection already exists' do
            let(:collection_name) { 'books' }
            let(:collection_options) do
              super().merge(name: collection_name)
            end
            let(:error_message) do
              "collection #{qualified_name} already exists"
            end

            before { create_collection(old: true) }

            describe 'with non-matching options' do
              it 'should raise an exception' do
                expect { create_collection(old: false, safe: false) }
                  .to raise_error(
                    described_class::DuplicateCollectionError,
                    error_message
                  )
              end

              it 'should not update the repository' do
                create_collection(old: false)

                collection = repository[qualified_name]

                expect(collection.options[:old]).to be true
              end
            end

            describe 'with matching options' do
              it 'should return the collection' do
                collection = create_collection(old: true)

                expect(collection.options[:old]).to be true
              end
            end
          end
        end

        describe '#key?' do
          it { expect(repository).to respond_to(:key?).with(1).argument }

          it { expect(repository.key?(nil)).to be false }

          it { expect(repository.key?(Object.new.freeze)).to be false }

          it { expect(repository.key?('invalid_name')).to be false }

          it { expect(repository.key?(:invalid_name)).to be false }

          wrap_context 'when the repository has many collections' do
            it { expect(repository.key?('invalid_name')).to be false }

            it { expect(repository.key?(:invalid_name)).to be false }

            it { expect(repository.key?(collections.keys.first)).to be true }

            it 'should include the key' do
              expect(repository.key?(collections.keys.first.intern)).to be true
            end
          end
        end

        describe '#keys' do
          include_examples 'should define reader', :keys, []

          wrap_context 'when the repository has many collections' do
            it { expect(repository.keys).to be == collections.keys }
          end
        end
      end
    end
  end
end
