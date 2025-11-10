# frozen_string_literal: true

require 'rspec/sleeping_king_studios/deferred'
require 'rspec/sleeping_king_studios/matchers/core/have_aliased_method'

require 'cuprum/collections/rspec/deferred'

module Cuprum::Collections::RSpec::Deferred
  # Deferred examples for validating Repository implementations.
  module RepositoryExamples
    include RSpec::SleepingKingStudios::Deferred::Provider

    # Initializes the repository with collection data.
    #
    # The including example group must define a #build_collection(**options)
    # method, which returns a valid collection instance for the repository.
    #
    # The default collections generated can be overriden by defining the
    # #configured_collections memoized helper in the including example group.
    deferred_context 'when the repository has many collections' do
      include RSpec::SleepingKingStudios::Deferred::Dependencies

      depends_on :build_collection,
        'builds a valid collection for the repository'

      let(:configured_collections) do
        next super() if defined?(super())

        [
          { name: 'authors' },
          { name: 'books', qualified_name: 'sources/books' },
          { name: 'publishers' }
        ]
      end
      let(:collections) do
        configured_collections.to_h do |options|
          collection = build_collection(**options)

          [collection.qualified_name, collection]
        end
      end

      before(:example) do
        collections.each_value { |collection| repository << collection }
      end
    end

    # Validates that the described class implements the Repository interface.
    #
    # The including example group must define a #build_collection(**options)
    # method, which returns a valid collection instance for the repository.
    deferred_examples 'should be a Repository' do |**deferred_options|
      deferred_examples 'should create the collection' do
        let(:configured_collection_class) do
          return super() if defined?(super())

          configured = deferred_options[:collection_class]

          # :nocov:
          configured = Object.const_get(configured) if configured.is_a?(String)
          # :nocov:

          configured
        end
        let(:configured_entity_class) do
          return super() if defined?(super())

          # :nocov:
          expected =
            if collection_options.key?(:entity_class)
              collection_options[:entity_class]
            elsif deferred_options.key?(:entity_class)
              deferred_options[:entity_class]
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

      let(:valid_collection) do
        next super() if defined?(super())

        build_collection(name: 'widgets', qualified_name: 'scope/widgets')
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

        wrap_deferred 'when the repository has many collections' do
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
          it { expect(repository.add(valid_collection)).to be repository }

          it 'should add the collection to the repository' do
            repository.add(valid_collection)

            expect(repository[valid_collection.qualified_name])
              .to be valid_collection
          end

          describe 'with force: true' do
            it 'should add the collection to the repository' do
              repository.add(valid_collection, force: true)

              expect(repository[valid_collection.qualified_name])
                .to be valid_collection
            end
          end

          context 'when the collection already exists' do
            let(:error_message) do
              "collection #{valid_collection.qualified_name} already exists"
            end

            before(:example) do
              allow(repository)
                .to receive(:key?)
                .with(valid_collection.qualified_name)
                .and_return(true)
            end

            it 'should raise an exception' do
              expect { repository.add(valid_collection) }
                .to raise_error(
                  described_class::DuplicateCollectionError,
                  error_message
                )
            end

            it 'should not update the repository' do
              begin
                repository.add(valid_collection)
              rescue described_class::DuplicateCollectionError
                # Do nothing.
              end

              expect { repository[valid_collection.qualified_name] }
                .to raise_error(
                  described_class::UndefinedCollectionError,
                  'repository does not define collection ' \
                  "#{valid_collection.qualified_name.inspect}"
                )
            end

            describe 'with force: true' do
              it 'should add the collection to the repository' do
                repository.add(valid_collection, force: true)

                expect(repository[valid_collection.qualified_name])
                  .to be valid_collection
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

        if deferred_options.fetch(:abstract, false)
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

          include_deferred 'should create the collection'
        end

        describe 'with entity_class: a String' do
          let(:entity_class) { 'Book' }
          let(:collection_options) do
            super().merge(entity_class:)
          end

          include_deferred 'should create the collection'
        end

        describe 'with name: a String' do
          let(:collection_name) { 'books' }
          let(:collection_options) do
            super().merge(name: collection_name)
          end

          include_deferred 'should create the collection'
        end

        describe 'with name: a Symbol' do
          let(:collection_name) { :books }
          let(:collection_options) do
            super().merge(name: collection_name)
          end

          include_deferred 'should create the collection'
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

          include_deferred 'should create the collection'
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

      describe '#find' do
        shared_examples 'should find the matching collection' do
          context 'when the collection does not exist' do
            let(:error_message) do
              "repository does not define collection #{qualified_name.inspect}"
            end

            it 'should raise an exception' do
              expect { repository.find(**collection_options) }.to raise_error(
                described_class::UndefinedCollectionError,
                error_message
              )
            end
          end

          next if deferred_options.fetch(:abstract, false)

          context 'when the collection exists' do
            include_deferred 'when the repository has many collections'

            let(:collection)     { collections.values.first }
            let(:entity_class)   { collection.entity_class }
            let(:name)           { collection.name }
            let(:qualified_name) { collection.qualified_name }

            it 'should find the collection' do
              expect(repository.find(**collection_options)).to be == collection
            end
          end
        end

        let(:name)               { 'books' }
        let(:qualified_name)     { name.to_s }
        let(:collection_options) { {} }

        it 'should define the method' do
          expect(repository)
            .to respond_to(:find)
            .with(0).arguments
            .and_any_keywords
        end

        describe 'with no parameters' do
          let(:error_message) { "name or entity class can't be blank" }

          it 'should raise an exception' do
            expect { repository.find }
              .to raise_error ArgumentError, error_message
          end
        end

        if deferred_options.fetch(:find_by_entity_class, true)
          describe 'with entity_class: a Class' do
            let(:entity_class)       { Book }
            let(:collection_options) { super().merge(entity_class:) }

            include_examples 'should find the matching collection'
          end

          describe 'with entity_class: a String' do
            let(:entity_class)       { 'Book' }
            let(:collection_options) { super().merge(entity_class:) }

            include_examples 'should find the matching collection'
          end
        end

        describe 'with name: a String' do
          let(:collection_options) { super().merge(name: name.to_s) }

          include_examples 'should find the matching collection'
        end

        describe 'with name: a Symbol' do
          let(:collection_options) { super().merge(name: name.intern) }

          include_examples 'should find the matching collection'
        end

        describe 'with qualified_name: a String' do
          let(:collection_options) do
            super().merge(qualified_name: qualified_name.to_s)
          end

          include_examples 'should find the matching collection'
        end

        describe 'with qualified_name: a Symbol' do
          let(:collection_options) do
            super().merge(qualified_name: qualified_name.intern)
          end

          include_examples 'should find the matching collection'
        end

        describe 'with multiple parameters' do
          let(:entity_class) { Book }
          let(:collection_options) do
            super().merge(entity_class:, qualified_name:)
          end

          context 'when the collection does not exist' do
            let(:error_message) do
              "repository does not define collection #{qualified_name.inspect}"
            end

            it 'should raise an exception' do
              expect { repository.find(**collection_options) }.to raise_error(
                described_class::UndefinedCollectionError,
                error_message
              )
            end
          end

          next if deferred_options.fetch(:abstract, false)

          context 'when a partially-matching collection exists' do
            include_deferred 'when the repository has many collections'

            let(:collection)     { collections.values.first }
            let(:entity_class)   { Spec::EntityClass }
            let(:qualified_name) { collection.qualified_name }
            let(:error_message) do
              <<~TEXT.strip
                collection "#{collection.qualified_name}" exists but does not match:

                  expected: #{{ entity_class: Spec::EntityClass }.inspect}
                    actual: #{{ entity_class: collection.entity_class }.inspect}
              TEXT
            end

            example_class 'Spec::EntityClass'

            it 'should raise an exception' do
              expect { repository.find(**collection_options) }.to raise_error(
                described_class::DuplicateCollectionError,
                error_message
              )
            end
          end

          context 'when a matching collection exists' do
            include_deferred 'when the repository has many collections'

            let(:collection)     { collections.values.first }
            let(:entity_class)   { collection.entity_class }
            let(:qualified_name) { collection.qualified_name }

            it 'should find the collection' do
              expect(repository.find(**collection_options)).to be == collection
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

        define_method :create_collection do |safe: true, **options|
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

        if deferred_options.fetch(:abstract, false)
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

        it 'should print a deprecation warning' do
          repository.find_or_create(qualified_name:)

          expect(SleepingKingStudios::Tools::Toolbelt.instance.core_tools)
            .to have_received(:deprecate)
            .with(
              "#{described_class.name}#find_or_create()",
              message: 'Use #create or #find method.'
            )
        end

        describe 'with entity_class: a Class' do
          let(:entity_class) { Book }
          let(:collection_options) do
            super().merge(entity_class:)
          end

          include_deferred 'should create the collection'
        end

        describe 'with entity_class: a String' do
          let(:entity_class) { Book }
          let(:collection_options) do
            super().merge(entity_class:)
          end

          include_deferred 'should create the collection'
        end

        describe 'with name: a String' do
          let(:collection_name) { 'books' }
          let(:collection_options) do
            super().merge(name: collection_name)
          end

          include_deferred 'should create the collection'
        end

        describe 'with name: a Symbol' do
          let(:collection_name) { :books }
          let(:collection_options) do
            super().merge(name: collection_name)
          end

          include_deferred 'should create the collection'
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

          include_deferred 'should create the collection'
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

        wrap_deferred 'when the repository has many collections' do
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

        wrap_deferred 'when the repository has many collections' do
          it { expect(repository.keys).to be == collections.keys }
        end
      end

      describe '#remove' do
        let(:qualified_name) { 'books' }

        it 'should define the method' do
          expect(repository)
            .to respond_to(:remove)
            .with(0).arguments
            .and_keywords(:qualified_name)
        end

        describe 'with qualified_name: a String' do
          let(:qualified_name) { super().to_s }

          context 'when the collection does not exist' do
            let(:error_message) do
              "repository does not define collection #{qualified_name.inspect}"
            end

            it 'should raise an exception' do
              expect { repository.remove(qualified_name:) }.to raise_error(
                described_class::UndefinedCollectionError,
                error_message
              )
            end
          end

          next if deferred_options.fetch(:abstract, false)

          context 'when the collection exists' do
            include_deferred 'when the repository has many collections'

            let(:collection)     { collections.values.first }
            let(:qualified_name) { collection.qualified_name.to_s }

            it 'should return the collection' do
              expect(repository.remove(qualified_name:)).to be == collection
            end

            it 'should remove the collection from the repository' do
              expect { repository.remove(qualified_name:) }
                .to change(repository, :keys)
                .to(satisfy { |keys| !keys.include?(qualified_name.to_s) })
            end
          end
        end

        describe 'with qualified_name: a Symbol' do
          let(:qualified_name) { super().intern }

          context 'when the collection does not exist' do
            let(:error_message) do
              'repository does not define collection ' \
                "#{qualified_name.to_s.inspect}"
            end

            it 'should raise an exception' do
              expect { repository.remove(qualified_name:) }.to raise_error(
                described_class::UndefinedCollectionError,
                error_message
              )
            end
          end

          next if deferred_options.fetch(:abstract, false)

          context 'when the collection exists' do
            include_deferred 'when the repository has many collections'

            let(:collection)     { collections.values.first }
            let(:qualified_name) { collection.qualified_name.intern }

            it 'should return the collection' do
              expect(repository.remove(qualified_name:)).to be == collection
            end

            it 'should remove the collection from the repository' do
              expect { repository.remove(qualified_name:) }
                .to change(repository, :keys)
                .to(satisfy { |keys| !keys.include?(qualified_name.to_s) })
            end
          end
        end
      end
    end
  end
end
