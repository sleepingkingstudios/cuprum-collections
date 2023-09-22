# frozen_string_literal: true

require 'cuprum/collections/rspec/contracts'
require 'cuprum/collections/rspec/contracts/relation_contracts'

module Cuprum::Collections::RSpec::Contracts
  # Contracts for asserting on Association objects.
  module AssociationContracts
    # Contract validating the behavior of an Association.
    module ShouldBeAnAssociationContract
      extend RSpec::SleepingKingStudios::Contract

      # @!method apply(example_group)
      #   Adds the contract to the example group.
      contract do
        include Cuprum::Collections::RSpec::Contracts::RelationContracts

        example_class 'Author'
        example_class 'Chapter'
        example_class 'Writer'

        include_contract 'should be a relation'

        include_contract 'should disambiguate parameter',
          :entity_class,
          as:    %i[association_class resource_class],
          value: Grimoire

        include_contract 'should disambiguate parameter',
          :name,
          as: %i[association_name resource_name]

        include_contract 'should disambiguate parameter',
          :singular_name,
          as: :singular_resource_name

        include_contract 'should define primary keys'

        describe '#build_entities_query' do
          it 'should define the method' do
            expect(association)
              .to respond_to(:build_entities_query)
              .with_unlimited_arguments
              .and_keywords(:allow_nil, :deduplicate)
          end
        end

        describe '#build_keys_query' do
          it 'should define the method' do
            expect(association)
              .to respond_to(:build_keys_query)
              .with_unlimited_arguments
              .and_keywords(:allow_nil, :deduplicate)
          end
        end

        describe '#foreign_key_name' do
          include_examples 'should define reader', :foreign_key_name
        end

        describe '#inverse' do
          include_examples 'should define reader', :inverse, nil

          context 'when initialized with inverse: value' do
            let(:inverse) { described_class.new(name: 'authors') }
            let(:constructor_options) do
              super().merge(inverse: inverse)
            end

            it { expect(subject.inverse).to be == inverse }
          end

          context 'with a copy with assigned inverse' do
            subject { super().with_inverse(new_inverse) }

            let(:new_inverse) { described_class.new(name: 'chapters') }

            it { expect(subject.inverse).to be == new_inverse }

            context 'when initialized with inverse: value' do
              let(:inverse) { described_class.new(name: 'authors') }
              let(:constructor_options) do
                super().merge(inverse: inverse)
              end

              it { expect(subject.inverse).to be == new_inverse }
            end
          end
        end

        describe '#inverse_class' do
          include_examples 'should define reader', :inverse_class, nil

          context 'when initialized with inverse: value' do
            let(:inverse) { described_class.new(name: 'authors') }
            let(:constructor_options) do
              super().merge(inverse: inverse)
            end

            it { expect(subject.inverse_class).to be == Author }

            context 'when initialized with inverse_class: a Class' do
              let(:constructor_options) do
                super().merge(inverse_class: Writer)
              end

              it { expect(subject.inverse_class).to be == Writer }
            end

            context 'when initialized with inverse_class: a String' do
              let(:constructor_options) do
                super().merge(inverse_class: 'Writer')
              end

              it { expect(subject.inverse_class).to be == Writer }
            end
          end

          context 'when initialized with inverse_class: a Class' do
            let(:constructor_options) do
              super().merge(inverse_class: Writer)
            end

            it { expect(subject.inverse_class).to be == Writer }
          end

          context 'when initialized with inverse_class: a String' do
            let(:constructor_options) do
              super().merge(inverse_class: 'Writer')
            end

            it { expect(subject.inverse_class).to be == Writer }
          end

          context 'with a copy with assigned inverse' do
            subject do
              super().tap(&:inverse_class).with_inverse(new_inverse)
            end

            let(:new_inverse) { described_class.new(name: 'chapters') }

            it { expect(subject.inverse_class).to be == Chapter }

            context 'when initialized with inverse_class: a Class' do
              let(:constructor_options) do
                super().merge(inverse_class: Writer)
              end

              it { expect(subject.inverse_class).to be == Writer }
            end

            context 'when initialized with inverse_class: a String' do
              let(:constructor_options) do
                super().merge(inverse_class: 'Writer')
              end

              it { expect(subject.inverse_class).to be == Writer }
            end

            context 'when initialized with inverse: value' do
              let(:inverse) { described_class.new(name: 'authors') }
              let(:constructor_options) do
                super().merge(inverse: inverse)
              end

              it { expect(subject.inverse_class).to be == Chapter }
            end
          end
        end

        describe '#inverse_name' do
          include_examples 'should define reader', :inverse_name, nil

          context 'when initialized with inverse: value' do
            let(:inverse) { described_class.new(name: 'authors') }
            let(:constructor_options) do
              super().merge(inverse: inverse)
            end

            it { expect(subject.inverse_name).to be == 'authors' }

            context 'when initialized with inverse_name: a String' do
              let(:constructor_options) do
                super().merge(inverse_name: 'writers')
              end

              it { expect(subject.inverse_name).to be == 'writers' }
            end

            context 'when initialized with inverse_name: a Symbol' do
              let(:constructor_options) do
                super().merge(inverse_name: :writers)
              end

              it { expect(subject.inverse_name).to be == 'writers' }
            end
          end

          context 'when initialized with inverse_name: a String' do
            let(:constructor_options) do
              super().merge(inverse_name: 'writers')
            end

            it { expect(subject.inverse_name).to be == 'writers' }
          end

          context 'when initialized with inverse_name: a Symbol' do
            let(:constructor_options) do
              super().merge(inverse_name: :writers)
            end

            it { expect(subject.inverse_name).to be == 'writers' }
          end

          context 'with a copy with assigned inverse' do
            subject do
              super().tap(&:inverse_name).with_inverse(new_inverse)
            end

            let(:new_inverse) { described_class.new(name: 'chapters') }

            it { expect(subject.inverse_name).to be == 'chapters' }

            context 'when initialized with inverse: value' do
              let(:inverse) { described_class.new(name: 'authors') }
              let(:constructor_options) do
                super().merge(inverse: inverse)
              end

              it { expect(subject.inverse_name).to be == 'chapters' }
            end

            context 'when initialized with inverse_name: a String' do
              let(:constructor_options) do
                super().merge(inverse_name: 'writers')
              end

              it { expect(subject.inverse_name).to be == 'writers' }
            end

            context 'when initialized with inverse_name: a Symbol' do
              let(:constructor_options) do
                super().merge(inverse_name: :writers)
              end

              it { expect(subject.inverse_name).to be == 'writers' }
            end
          end
        end

        describe '#map_entities_to_keys' do
          it 'should define the method' do
            expect(subject)
              .to respond_to(:map_entities_to_keys)
              .with_unlimited_arguments
              .and_keywords(:allow_nil, :deduplicate, :strict)
          end
        end

        describe '#options' do
          context 'when initialized with inverse: value' do
            let(:inverse) { described_class.new(name: 'authors') }
            let(:constructor_options) do
              super().merge(inverse: inverse)
            end

            it { expect(subject.options).to be == {} }
          end
        end

        describe '#plural?' do
          include_examples 'should define predicate', :plural?
        end

        describe '#primary_key_query?' do
          include_examples 'should define predicate', :primary_key_query?
        end

        describe '#query_key_name' do
          include_examples 'should define reader', :query_key_name
        end

        describe '#singular_inverse_name' do
          include_examples 'should define reader', :singular_inverse_name, nil

          context 'when initialized with inverse: value' do
            let(:inverse) { described_class.new(name: 'authors') }
            let(:constructor_options) do
              super().merge(inverse: inverse)
            end

            it { expect(subject.singular_inverse_name).to be == 'author' }

            context 'when initialized with singular_inverse_name: a String' do
              let(:singular_inverse_name) { 'writer' }
              let(:constructor_options) do
                super().merge(singular_inverse_name: singular_inverse_name)
              end

              it { expect(subject.singular_inverse_name).to be == 'writer' }
            end

            context 'when initialized with singular_inverse_name: a Symbol' do
              let(:singular_inverse_name) { :writer }
              let(:constructor_options) do
                super().merge(singular_inverse_name: singular_inverse_name)
              end

              it { expect(subject.singular_inverse_name).to be == 'writer' }
            end
          end

          context 'when initialized with inverse_name: value' do
            let(:inverse_name) { 'authors' }
            let(:constructor_options) do
              super().merge(inverse_name: inverse_name)
            end

            it { expect(subject.singular_inverse_name).to be == 'author' }

            context 'when initialized with singular_inverse_name: a String' do
              let(:singular_inverse_name) { 'writer' }
              let(:constructor_options) do
                super().merge(singular_inverse_name: singular_inverse_name)
              end

              it { expect(subject.singular_inverse_name).to be == 'writer' }
            end

            context 'when initialized with singular_inverse_name: a Symbol' do
              let(:singular_inverse_name) { :writer }
              let(:constructor_options) do
                super().merge(singular_inverse_name: singular_inverse_name)
              end

              it { expect(subject.singular_inverse_name).to be == 'writer' }
            end
          end

          context 'when initialized with singular_inverse_name: a String' do
            let(:singular_inverse_name) { 'writer' }
            let(:constructor_options) do
              super().merge(singular_inverse_name: singular_inverse_name)
            end

            it { expect(subject.singular_inverse_name).to be == 'writer' }
          end

          context 'when initialized with singular_inverse_name: a Symbol' do
            let(:singular_inverse_name) { :writer }
            let(:constructor_options) do
              super().merge(singular_inverse_name: singular_inverse_name)
            end

            it { expect(subject.singular_inverse_name).to be == 'writer' }
          end

          context 'with a copy with assigned inverse' do
            subject do
              super().tap(&:singular_inverse_name).with_inverse(new_inverse)
            end

            let(:new_inverse) { described_class.new(name: 'chapters') }

            it { expect(subject.singular_inverse_name).to be == 'chapter' }

            context 'when initialized with inverse: value' do
              let(:inverse) { described_class.new(name: 'authors') }
              let(:constructor_options) do
                super().merge(inverse: inverse)
              end

              it { expect(subject.singular_inverse_name).to be == 'chapter' }
            end

            context 'when initialized with inverse_name: value' do
              let(:inverse_name) { 'authors' }
              let(:constructor_options) do
                super().merge(inverse_name: inverse_name)
              end

              it { expect(subject.singular_inverse_name).to be == 'chapter' }

              context 'when initialized with singular_inverse_name: a String' do
                let(:singular_inverse_name) { 'writer' }
                let(:constructor_options) do
                  super().merge(singular_inverse_name: singular_inverse_name)
                end

                it { expect(subject.singular_inverse_name).to be == 'writer' }
              end

              context 'when initialized with singular_inverse_name: a Symbol' do
                let(:singular_inverse_name) { :writer }
                let(:constructor_options) do
                  super().merge(singular_inverse_name: singular_inverse_name)
                end

                it { expect(subject.singular_inverse_name).to be == 'writer' }
              end
            end

            context 'when initialized with singular_inverse_name: a String' do
              let(:singular_inverse_name) { 'writer' }
              let(:constructor_options) do
                super().merge(singular_inverse_name: singular_inverse_name)
              end

              it { expect(subject.singular_inverse_name).to be == 'writer' }
            end

            context 'when initialized with singular_inverse_name: a Symbol' do
              let(:singular_inverse_name) { :writer }
              let(:constructor_options) do
                super().merge(singular_inverse_name: singular_inverse_name)
              end

              it { expect(subject.singular_inverse_name).to be == 'writer' }
            end
          end
        end

        describe '#singular?' do
          include_examples 'should define predicate', :singular?
        end

        describe '#with_inverse' do
          it 'should define the method' do
            expect(association).to respond_to(:with_inverse).with(1).argument
          end

          context 'with a copy with assigned inverse' do
            let(:new_inverse) { described_class.new(name: 'chapters') }
            let(:copy)        { subject.with_inverse(new_inverse) }

            it { expect(copy).to be_a described_class }

            it { expect(copy.inverse).to be == new_inverse }

            it { expect(subject.inverse).to be nil }
          end
        end
      end
    end

    # Contract validating the behavior of a BelongsToAssociation.
    module ShouldBeABelongsToAssociationContract
      extend RSpec::SleepingKingStudios::Contract

      # @!method apply(example_group)
      #   Adds the contract to the example group.
      contract do
        include Cuprum::Collections::RSpec::Contracts::RelationContracts

        include_contract 'should be an association'

        describe '#build_entities_query' do
          let(:key)      { subject.foreign_key_name }
          let(:entities) { [] }
          let(:options)  { {} }
          let(:query) do
            association.build_entities_query(*entities, **options)
          end
          let(:evaluated) do
            Spec::QueryBuilder.new.instance_exec(&query)
          end

          example_class 'Spec::Entity' do |klass|
            klass.define_method(:initialize) do |**attributes|
              attributes.each do |key, value|
                instance_variable_set(:"@#{key}", value)
              end
            end

            klass.attr_reader :book_id
          end

          example_class 'Spec::QueryBuilder' do |klass|
            klass.define_method(:one_of) { |values| { 'one_of' => values } }
          end

          describe 'with no entities' do
            let(:entities) { [] }

            it { expect(query).to be_a Proc }

            it { expect(evaluated).to be == {} }
          end

          describe 'with one nil entity' do
            let(:entities) { [nil] }

            it { expect(evaluated).to be == {} }
          end

          describe 'with one invalid entity' do
            let(:entities) { [Object.new.freeze] }
            let(:error_message) do
              "undefined method :[] or :#{key} for #{entities.first.inspect}"
            end

            it 'should raise an exception' do
              expect { association.build_entities_query(*entities) }
                .to raise_error ArgumentError, error_message
            end
          end

          describe 'with one entity that responds to #[] and key: nil' do
            let(:entities) { [{ key => nil }] }

            it { expect(evaluated).to be == {} }

            describe 'with allow_nil: true' do
              let(:options) { super().merge(allow_nil: true) }

              it { expect(evaluated).to be == { 'id' => nil } }
            end
          end

          describe 'with one entity that responds to #[] and key: value' do
            let(:entities) { [{ key => 0 }] }

            it { expect(evaluated).to be == { 'id' => 0 } }
          end

          describe 'with one entity that responds to #id and key: nil' do
            let(:entities) { [Spec::Entity.new(key => nil)] }

            it { expect(evaluated).to be == {} }

            describe 'with allow_nil: true' do
              let(:options) { super().merge(allow_nil: true) }

              it { expect(evaluated).to be == { 'id' => nil } }
            end
          end

          describe 'with one entity that responds to #id and key: value' do
            let(:entities) { [Spec::Entity.new(key => 0)] }

            it { expect(evaluated).to be == { 'id' => 0 } }
          end

          describe 'with multiple entities' do
            let(:entities) do
              [
                Spec::Entity.new(key => 0),
                Spec::Entity.new(key => 1),
                Spec::Entity.new(key => 2)
              ]
            end
            let(:expected) do
              { 'id' => { 'one_of' => [0, 1, 2] } }
            end

            it { expect(evaluated).to be == expected }
          end

          describe 'with multiple entities including nil' do
            let(:entities) do
              [
                Spec::Entity.new(key => 0),
                nil,
                Spec::Entity.new(key => 1),
                nil,
                Spec::Entity.new(key => 2)
              ]
            end
            let(:expected) do
              { 'id' => { 'one_of' => [0, 1, 2] } }
            end

            it { expect(evaluated).to be == expected }
          end

          describe 'with multiple entities including nil ids' do
            let(:entities) do
              [
                Spec::Entity.new(key => 0),
                Spec::Entity.new(key => nil),
                Spec::Entity.new(key => 1),
                Spec::Entity.new(key => nil),
                Spec::Entity.new(key => 2)
              ]
            end
            let(:expected) do
              { 'id' => { 'one_of' => [0, 1, 2] } }
            end

            it { expect(evaluated).to be == expected }

            describe 'with allow_nil: true' do
              let(:options) { super().merge(allow_nil: true) }
              let(:expected) do
                { 'id' => { 'one_of' => [0, nil, 1, 2] } }
              end

              it { expect(evaluated).to be == expected }
            end
          end

          describe 'with multiple entities including duplicate ids' do
            let(:entities) do
              [
                Spec::Entity.new(key => 0),
                Spec::Entity.new(key => 1),
                Spec::Entity.new(key => 0),
                Spec::Entity.new(key => 1),
                Spec::Entity.new(key => 2)
              ]
            end
            let(:expected) do
              { 'id' => { 'one_of' => [0, 1, 2] } }
            end

            it { expect(evaluated).to be == expected }

            describe 'with deduplicate: false' do
              let(:options) { super().merge(deduplicate: false) }
              let(:expected) do
                { 'id' => { 'one_of' => [0, 1, 0, 1, 2] } }
              end

              it { expect(evaluated).to be == expected }
            end
          end
        end

        describe '#build_keys_query' do
          let(:keys)    { [] }
          let(:options) { {} }
          let(:query) do
            association.build_keys_query(*keys, **options)
          end
          let(:evaluated) do
            Spec::QueryBuilder.new.instance_exec(&query)
          end

          example_class 'Spec::QueryBuilder' do |klass|
            klass.define_method(:one_of) { |values| { 'one_of' => values } }
          end

          describe 'with no keys' do
            let(:keys) { [] }

            it { expect(query).to be_a Proc }

            it { expect(evaluated).to be == {} }
          end

          describe 'with one nil key' do
            let(:keys) { [nil] }

            it { expect(evaluated).to be == {} }

            describe 'with allow_nil: true' do
              let(:options) { { allow_nil: true } }

              it { expect(evaluated).to be == { 'id' => nil } }
            end
          end

          describe 'with one non-nil key' do
            let(:keys) { [0] }

            it { expect(evaluated).to be == { 'id' => 0 } }
          end

          describe 'with many keys' do
            let(:keys)     { [0, 1, 2] }
            let(:expected) { { 'id' => { 'one_of' => keys } } }

            it { expect(evaluated).to be == expected }
          end

          describe 'with many keys including nil' do
            let(:keys)     { [0, nil, 2] }
            let(:expected) { { 'id' => { 'one_of' => [0, 2] } } }

            it { expect(evaluated).to be == expected }

            describe 'with allow_nil: true' do
              let(:options) { { allow_nil: true } }
              let(:expected) do
                { 'id' => { 'one_of' => [0, nil, 2] } }
              end

              it { expect(evaluated).to be == expected }
            end
          end

          describe 'with many non-unique keys' do
            let(:keys)     { [0, 1, 2, 1, 2] }
            let(:expected) { { 'id' => { 'one_of' => keys.uniq } } }

            it { expect(evaluated).to be == expected }

            describe 'with deduplicate: false' do
              let(:options) { super().merge(deduplicate: false) }
              let(:expected) do
                { 'id' => { 'one_of' => [0, 1, 2, 1, 2] } }
              end

              it { expect(evaluated).to be == expected }
            end
          end
        end

        describe '#foreign_key_name' do
          let(:expected) { "#{tools.str.singularize(name)}_id" }

          def tools
            SleepingKingStudios::Tools::Toolbelt.instance
          end

          it { expect(subject.foreign_key_name).to be == expected }

          context 'when initialized with foreign_key_name: a String' do
            let(:foreign_key_name) { 'writer_id' }
            let(:constructor_options) do
              super().merge(foreign_key_name: foreign_key_name)
            end

            it { expect(subject.foreign_key_name).to be == 'writer_id' }
          end

          context 'when initialized with foreign_key_name: a String' do
            let(:foreign_key_name) { :writer_id }
            let(:constructor_options) do
              super().merge(foreign_key_name: foreign_key_name)
            end

            it { expect(subject.foreign_key_name).to be == 'writer_id' }
          end

          context 'when initialized with singular_name: value' do
            let(:singular_name) { 'author' }
            let(:constructor_options) do
              super().merge(singular_name: singular_name)
            end

            it { expect(subject.foreign_key_name).to be == 'author_id' }

            context 'when initialized with foreign_key_name: a String' do
              let(:foreign_key_name) { 'writer_id' }
              let(:constructor_options) do
                super().merge(foreign_key_name: foreign_key_name)
              end

              it { expect(subject.foreign_key_name).to be == 'writer_id' }
            end

            context 'when initialized with foreign_key_name: a String' do
              let(:foreign_key_name) { :writer_id }
              let(:constructor_options) do
                super().merge(foreign_key_name: foreign_key_name)
              end

              it { expect(subject.foreign_key_name).to be == 'writer_id' }
            end
          end
        end

        describe '#map_entities_to_keys' do
          let(:key)      { subject.foreign_key_name }
          let(:entities) { [] }
          let(:options)  { {} }
          let(:keys) do
            association.map_entities_to_keys(*entities, **options)
          end

          example_class 'Spec::Entity' do |klass|
            klass.define_method(:initialize) do |**attributes|
              attributes.each do |key, value|
                instance_variable_set(:"@#{key}", value)
              end
            end

            klass.attr_reader :book_id
          end

          describe 'with no entities' do
            let(:entities) { [] }

            it { expect(keys).to be == [] }
          end

          describe 'with one nil entity' do
            let(:entities) { [nil] }

            it { expect(keys).to be == [] }
          end

          describe 'with one invalid entity' do
            let(:entities) { [Object.new.freeze] }
            let(:error_message) do
              "undefined method :[] or :#{key} for #{entities.first.inspect}"
            end

            it 'should raise an exception' do
              expect { association.map_entities_to_keys(*entities) }
                .to raise_error ArgumentError, error_message
            end

            describe 'with strict: false' do
              it 'should raise an exception' do
                expect do
                  association.map_entities_to_keys(*entities, strict: false)
                end
                  .to raise_error ArgumentError, error_message
              end
            end
          end

          describe 'with one Integer' do
            let(:entities) { [0] }
            let(:error_message) do
              "undefined method :[] or :#{key} for #{entities.first.inspect}"
            end

            it 'should raise an exception' do
              expect { association.map_entities_to_keys(*entities) }
                .to raise_error ArgumentError, error_message
            end

            describe 'with strict: false' do
              it 'should raise an exception' do
                expect(
                  association.map_entities_to_keys(*entities, strict: false)
                )
                  .to be == entities
              end
            end

            context 'when initialized with primary_key_type: String' do
              let(:constructor_options) do
                super().merge(primary_key_type: String)
              end

              describe 'with strict: false' do
                it 'should raise an exception' do
                  expect do
                    association.map_entities_to_keys(*entities, strict: false)
                  end
                    .to raise_error ArgumentError, error_message
                end
              end
            end
          end

          describe 'with one String' do
            let(:entities) { %w[0] }
            let(:error_message) do
              "undefined method :[] or :#{key} for #{entities.first.inspect}"
            end

            it 'should raise an exception' do
              expect { association.map_entities_to_keys(*entities) }
                .to raise_error ArgumentError, error_message
            end

            describe 'with strict: false' do
              it 'should raise an exception' do
                expect do
                  association.map_entities_to_keys(*entities, strict: false)
                end
                  .to raise_error ArgumentError, error_message
              end
            end

            context 'when initialized with primary_key_type: String' do
              let(:constructor_options) do
                super().merge(primary_key_type: String)
              end

              describe 'with strict: false' do
                it 'should raise an exception' do
                  expect(
                    association.map_entities_to_keys(*entities, strict: false)
                  )
                    .to be == entities
                end
              end
            end
          end

          describe 'with one entity that responds to #[] and key: nil' do
            let(:entities) { [{ key => nil }] }

            it { expect(keys).to be == [] }

            describe 'with allow_nil: true' do
              let(:options) { super().merge(allow_nil: true) }

              it { expect(keys).to be == [nil] }
            end
          end

          describe 'with one entity that responds to #[] and key: value' do
            let(:entities) { [{ key => 0 }] }

            it { expect(keys).to be == [0] }
          end

          describe 'with one entity that responds to #id and key: nil' do
            let(:entities) { [Spec::Entity.new(key => nil)] }

            it { expect(keys).to be == [] }

            describe 'with allow_nil: true' do
              let(:options) { super().merge(allow_nil: true) }

              it { expect(keys).to be == [nil] }
            end
          end

          describe 'with one entity that responds to #id and key: value' do
            let(:entities) { [Spec::Entity.new(key => 0)] }

            it { expect(keys).to be == [0] }
          end

          describe 'with multiple entities' do
            let(:entities) do
              [
                Spec::Entity.new(key => 0),
                Spec::Entity.new(key => 1),
                Spec::Entity.new(key => 2)
              ]
            end

            it { expect(keys).to be == [0, 1, 2] }
          end

          describe 'with multiple entities including nil' do
            let(:entities) do
              [
                Spec::Entity.new(key => 0),
                nil,
                Spec::Entity.new(key => 1),
                nil,
                Spec::Entity.new(key => 2)
              ]
            end

            it { expect(keys).to be == [0, 1, 2] }
          end

          describe 'with multiple entities including nil ids' do
            let(:entities) do
              [
                Spec::Entity.new(key => 0),
                Spec::Entity.new(key => nil),
                Spec::Entity.new(key => 1),
                Spec::Entity.new(key => nil),
                Spec::Entity.new(key => 2)
              ]
            end

            it { expect(keys).to be == [0, 1, 2] }

            describe 'with allow_nil: true' do
              let(:options) { super().merge(allow_nil: true) }

              it { expect(keys).to be == [0, nil, 1, 2] }
            end
          end

          describe 'with multiple entities including duplicate ids' do
            let(:entities) do
              [
                Spec::Entity.new(key => 0),
                Spec::Entity.new(key => 1),
                Spec::Entity.new(key => 0),
                Spec::Entity.new(key => 1),
                Spec::Entity.new(key => 2)
              ]
            end

            it { expect(keys).to be == [0, 1, 2] }

            describe 'with deduplicate: false' do
              let(:options) { super().merge(deduplicate: false) }

              it { expect(keys).to be == [0, 1, 0, 1, 2] }
            end
          end

          describe 'with multiple Integers' do
            let(:entities) { [0, 1, 2] }
            let(:error_message) do
              "undefined method :[] or :#{key} for #{entities.first.inspect}"
            end

            it 'should raise an exception' do
              expect { association.map_entities_to_keys(*entities) }
                .to raise_error ArgumentError, error_message
            end

            describe 'with strict: false' do
              it 'should raise an exception' do
                expect(
                  association.map_entities_to_keys(*entities, strict: false)
                )
                  .to be == entities
              end
            end

            context 'when initialized with primary_key_type: String' do
              let(:constructor_options) do
                super().merge(primary_key_type: String)
              end

              describe 'with strict: false' do
                it 'should raise an exception' do
                  expect do
                    association.map_entities_to_keys(*entities, strict: false)
                  end
                    .to raise_error ArgumentError, error_message
                end
              end
            end
          end

          describe 'with multiple Strings' do
            let(:entities) { %w[0 1 2] }
            let(:error_message) do
              "undefined method :[] or :#{key} for #{entities.first.inspect}"
            end

            it 'should raise an exception' do
              expect { association.map_entities_to_keys(*entities) }
                .to raise_error ArgumentError, error_message
            end

            describe 'with strict: false' do
              it 'should raise an exception' do
                expect do
                  association.map_entities_to_keys(*entities, strict: false)
                end
                  .to raise_error ArgumentError, error_message
              end
            end

            context 'when initialized with primary_key_type: String' do
              let(:constructor_options) do
                super().merge(primary_key_type: String)
              end

              describe 'with strict: false' do
                it 'should raise an exception' do
                  expect(
                    association.map_entities_to_keys(*entities, strict: false)
                  )
                    .to be == entities
                end
              end
            end
          end
        end

        describe '#primary_key_query?' do
          it { expect(subject.primary_key_query?).to be true }
        end

        describe '#query_key_name' do
          it { expect(subject.query_key_name).to be == 'id' }

          context 'when initialized with primary_key_name: a String' do
            let(:primary_key_name) { 'uuid' }
            let(:constructor_options) do
              super().merge(primary_key_name: primary_key_name)
            end

            it { expect(subject.query_key_name).to be == primary_key_name }
          end

          context 'when initialized with primary_key_name: a Symbol' do
            let(:primary_key_name) { :uuid }
            let(:constructor_options) do
              super().merge(primary_key_name: primary_key_name)
            end

            it 'should set the primary key name' do
              expect(subject.query_key_name).to be == primary_key_name.to_s
            end
          end
        end
      end
    end

    # Contract validating the behavior of a HasAssociation.
    module ShouldBeAHasAssociationContract
      extend RSpec::SleepingKingStudios::Contract

      # @!method apply(example_group)
      #   Adds the contract to the example group.
      contract do
        include Cuprum::Collections::RSpec::Contracts::RelationContracts

        include_contract 'should be an association'

        describe '#build_entities_query' do
          let(:key)      { subject.primary_key_name }
          let(:entities) { [] }
          let(:options)  { {} }
          let(:query) do
            association.build_entities_query(*entities, **options)
          end
          let(:evaluated) do
            Spec::QueryBuilder.new.instance_exec(&query)
          end

          example_class 'Spec::Entity' do |klass|
            klass.define_method(:initialize) do |**attributes|
              attributes.each do |key, value|
                instance_variable_set(:"@#{key}", value)
              end
            end

            klass.attr_reader :id
          end

          example_class 'Spec::QueryBuilder' do |klass|
            klass.define_method(:one_of) { |values| { 'one_of' => values } }
          end

          context 'when the foreign key name is blank' do
            let(:error_message) do
              "foreign key name can't be blank"
            end

            it 'should raise an exception' do
              expect { association.build_entities_query(*entities) }
                .to raise_error ArgumentError, error_message
            end
          end

          context 'when initialized with foreign_key_name: value' do
            let(:foreign_key_name) { 'author_id' }
            let(:constructor_options) do
              super().merge(foreign_key_name: foreign_key_name)
            end

            describe 'with no entities' do
              let(:entities) { [] }

              it { expect(query).to be_a Proc }

              it { expect(evaluated).to be == {} }
            end

            describe 'with one nil entity' do
              let(:entities) { [nil] }

              it { expect(evaluated).to be == {} }
            end

            describe 'with one invalid entity' do
              let(:entities) { [Object.new.freeze] }
              let(:error_message) do
                "undefined method :[] or :#{key} for #{entities.first.inspect}"
              end

              it 'should raise an exception' do
                expect { association.build_entities_query(*entities) }
                  .to raise_error ArgumentError, error_message
              end
            end

            describe 'with one entity that responds to #[] and key: nil' do
              let(:entities) { [{ key => nil }] }

              it { expect(evaluated).to be == {} }

              describe 'with allow_nil: true' do
                let(:options) { super().merge(allow_nil: true) }

                it { expect(evaluated).to be == { 'author_id' => nil } }
              end
            end

            describe 'with one entity that responds to #[] and key: value' do
              let(:entities) { [{ key => 0 }] }

              it { expect(evaluated).to be == { 'author_id' => 0 } }
            end

            describe 'with one entity that responds to #id and key: nil' do
              let(:entities) { [Spec::Entity.new(key => nil)] }

              it { expect(evaluated).to be == {} }

              describe 'with allow_nil: true' do
                let(:options) { super().merge(allow_nil: true) }

                it { expect(evaluated).to be == { 'author_id' => nil } }
              end
            end

            describe 'with one entity that responds to #id and key: value' do
              let(:entities) { [Spec::Entity.new(key => 0)] }

              it { expect(evaluated).to be == { 'author_id' => 0 } }
            end

            describe 'with multiple entities' do
              let(:entities) do
                [
                  Spec::Entity.new(key => 0),
                  Spec::Entity.new(key => 1),
                  Spec::Entity.new(key => 2)
                ]
              end
              let(:expected) do
                { 'author_id' => { 'one_of' => [0, 1, 2] } }
              end

              it { expect(evaluated).to be == expected }
            end

            describe 'with multiple entities including nil' do
              let(:entities) do
                [
                  Spec::Entity.new(key => 0),
                  nil,
                  Spec::Entity.new(key => 1),
                  nil,
                  Spec::Entity.new(key => 2)
                ]
              end
              let(:expected) do
                { 'author_id' => { 'one_of' => [0, 1, 2] } }
              end

              it { expect(evaluated).to be == expected }
            end

            describe 'with multiple entities including nil ids' do
              let(:entities) do
                [
                  Spec::Entity.new(key => 0),
                  Spec::Entity.new(key => nil),
                  Spec::Entity.new(key => 1),
                  Spec::Entity.new(key => nil),
                  Spec::Entity.new(key => 2)
                ]
              end
              let(:expected) do
                { 'author_id' => { 'one_of' => [0, 1, 2] } }
              end

              it { expect(evaluated).to be == expected }

              describe 'with allow_nil: true' do
                let(:options) { super().merge(allow_nil: true) }
                let(:expected) do
                  { 'author_id' => { 'one_of' => [0, nil, 1, 2] } }
                end

                it { expect(evaluated).to be == expected }
              end
            end

            describe 'with multiple entities including duplicate ids' do
              let(:entities) do
                [
                  Spec::Entity.new(key => 0),
                  Spec::Entity.new(key => 1),
                  Spec::Entity.new(key => 0),
                  Spec::Entity.new(key => 1),
                  Spec::Entity.new(key => 2)
                ]
              end
              let(:expected) do
                { 'author_id' => { 'one_of' => [0, 1, 2] } }
              end

              it { expect(evaluated).to be == expected }

              describe 'with deduplicate: false' do
                let(:options) { super().merge(deduplicate: false) }
                let(:expected) do
                  { 'author_id' => { 'one_of' => [0, 1, 0, 1, 2] } }
                end

                it { expect(evaluated).to be == expected }
              end
            end
          end
        end

        describe '#build_keys_query' do
          let(:keys)    { [] }
          let(:options) { {} }
          let(:query) do
            association.build_keys_query(*keys, **options)
          end
          let(:evaluated) do
            Spec::QueryBuilder.new.instance_exec(&query)
          end

          example_class 'Spec::QueryBuilder' do |klass|
            klass.define_method(:one_of) { |values| { 'one_of' => values } }
          end

          context 'when the foreign key name is blank' do
            let(:error_message) do
              "foreign key name can't be blank"
            end

            it 'should raise an exception' do
              expect { association.build_keys_query(*keys) }
                .to raise_error ArgumentError, error_message
            end
          end

          context 'when initialized with foreign_key_name: value' do
            let(:foreign_key_name) { 'author_id' }
            let(:constructor_options) do
              super().merge(foreign_key_name: foreign_key_name)
            end

            describe 'with no keys' do
              let(:keys) { [] }

              it { expect(query).to be_a Proc }

              it { expect(evaluated).to be == {} }
            end

            describe 'with one nil key' do
              let(:keys) { [nil] }

              it { expect(evaluated).to be == {} }

              describe 'with allow_nil: true' do
                let(:options) { { allow_nil: true } }

                it { expect(evaluated).to be == { 'author_id' => nil } }
              end
            end

            describe 'with one non-nil key' do
              let(:keys) { [0] }

              it { expect(evaluated).to be == { 'author_id' => 0 } }
            end

            describe 'with many keys' do
              let(:keys)     { [0, 1, 2] }
              let(:expected) { { 'author_id' => { 'one_of' => keys } } }

              it { expect(evaluated).to be == expected }
            end

            describe 'with many keys including nil' do
              let(:keys)     { [0, nil, 2] }
              let(:expected) { { 'author_id' => { 'one_of' => [0, 2] } } }

              it { expect(evaluated).to be == expected }

              describe 'with allow_nil: true' do
                let(:options) { { allow_nil: true } }
                let(:expected) do
                  { 'author_id' => { 'one_of' => [0, nil, 2] } }
                end

                it { expect(evaluated).to be == expected }
              end
            end

            describe 'with many non-unique keys' do
              let(:keys)     { [0, 1, 2, 1, 2] }
              let(:expected) { { 'author_id' => { 'one_of' => keys.uniq } } }

              it { expect(evaluated).to be == expected }

              describe 'with deduplicate: false' do
                let(:options) { super().merge(deduplicate: false) }
                let(:expected) do
                  { 'author_id' => { 'one_of' => [0, 1, 2, 1, 2] } }
                end

                it { expect(evaluated).to be == expected }
              end
            end
          end
        end

        describe '#foreign_key_name' do
          it { expect(subject.foreign_key_name).to be nil }

          context 'when initialized with foreign_key_name: a String' do
            let(:foreign_key_name) { 'writer_id' }
            let(:constructor_options) do
              super().merge(foreign_key_name: foreign_key_name)
            end

            it { expect(subject.foreign_key_name).to be == 'writer_id' }
          end

          context 'when initialized with foreign_key_name: a String' do
            let(:foreign_key_name) { :writer_id }
            let(:constructor_options) do
              super().merge(foreign_key_name: foreign_key_name)
            end

            it { expect(subject.foreign_key_name).to be == 'writer_id' }
          end

          context 'when initialized with inverse: value' do
            let(:inverse) { described_class.new(name: 'authors') }
            let(:constructor_options) do
              super().merge(inverse: inverse)
            end

            it { expect(subject.foreign_key_name).to be == 'author_id' }

            context 'when initialized with foreign_key_name: a String' do
              let(:foreign_key_name) { 'writer_id' }
              let(:constructor_options) do
                super().merge(foreign_key_name: foreign_key_name)
              end

              it { expect(subject.foreign_key_name).to be == 'writer_id' }
            end

            context 'when initialized with foreign_key_name: a String' do
              let(:foreign_key_name) { :writer_id }
              let(:constructor_options) do
                super().merge(foreign_key_name: foreign_key_name)
              end

              it { expect(subject.foreign_key_name).to be == 'writer_id' }
            end

            context 'when initialized with inverse_name: value' do
              let(:inverse_name) { 'writers' }
              let(:constructor_options) do
                super().merge(inverse_name: inverse_name)
              end

              it { expect(subject.foreign_key_name).to be == 'author_id' }
            end

            context 'when initialized with singular_inverse_name: value' do
              let(:singular_inverse_name) { 'writer' }
              let(:constructor_options) do
                super().merge(singular_inverse_name: singular_inverse_name)
              end

              it { expect(subject.foreign_key_name).to be == 'writer_id' }
            end
          end

          context 'when initialized with inverse_name: value' do
            let(:inverse_name) { 'authors' }
            let(:constructor_options) do
              super().merge(inverse_name: inverse_name)
            end

            it { expect(subject.foreign_key_name).to be == 'author_id' }

            context 'when initialized with foreign_key_name: a String' do
              let(:foreign_key_name) { 'writer_id' }
              let(:constructor_options) do
                super().merge(foreign_key_name: foreign_key_name)
              end

              it { expect(subject.foreign_key_name).to be == 'writer_id' }
            end

            context 'when initialized with foreign_key_name: a String' do
              let(:foreign_key_name) { :writer_id }
              let(:constructor_options) do
                super().merge(foreign_key_name: foreign_key_name)
              end

              it { expect(subject.foreign_key_name).to be == 'writer_id' }
            end
          end

          context 'when initialized with singular_inverse_name: value' do
            let(:singular_inverse_name) { 'author' }
            let(:constructor_options) do
              super().merge(singular_inverse_name: singular_inverse_name)
            end

            it { expect(subject.foreign_key_name).to be == 'author_id' }

            context 'when initialized with foreign_key_name: a String' do
              let(:foreign_key_name) { 'writer_id' }
              let(:constructor_options) do
                super().merge(foreign_key_name: foreign_key_name)
              end

              it { expect(subject.foreign_key_name).to be == 'writer_id' }
            end

            context 'when initialized with foreign_key_name: a String' do
              let(:foreign_key_name) { :writer_id }
              let(:constructor_options) do
                super().merge(foreign_key_name: foreign_key_name)
              end

              it { expect(subject.foreign_key_name).to be == 'writer_id' }
            end
          end

          context 'with a copy with assigned inverse' do
            subject do
              super().tap(&:foreign_key_name).with_inverse(new_inverse)
            end

            let(:new_inverse) { described_class.new(name: 'chapters') }

            it { expect(subject.foreign_key_name).to be == 'chapter_id' }

            context 'when initialized with foreign_key_name: a String' do
              let(:foreign_key_name) { 'writer_id' }
              let(:constructor_options) do
                super().merge(foreign_key_name: foreign_key_name)
              end

              it { expect(subject.foreign_key_name).to be == 'writer_id' }
            end

            context 'when initialized with foreign_key_name: a String' do
              let(:foreign_key_name) { :writer_id }
              let(:constructor_options) do
                super().merge(foreign_key_name: foreign_key_name)
              end

              it { expect(subject.foreign_key_name).to be == 'writer_id' }
            end

            context 'when initialized with inverse: value' do
              let(:inverse) { described_class.new(name: 'authors') }
              let(:constructor_options) do
                super().merge(inverse: inverse)
              end

              it { expect(subject.foreign_key_name).to be == 'chapter_id' }
            end

            context 'when initialized with inverse_name: value' do
              let(:inverse_name) { 'authors' }
              let(:constructor_options) do
                super().merge(inverse_name: inverse_name)
              end

              it { expect(subject.foreign_key_name).to be == 'chapter_id' }
            end

            context 'when initialized with singular_inverse_name: value' do
              let(:singular_inverse_name) { 'author' }
              let(:constructor_options) do
                super().merge(singular_inverse_name: singular_inverse_name)
              end

              it { expect(subject.foreign_key_name).to be == 'author_id' }
            end
          end
        end

        describe '#map_entities_to_keys' do
          let(:key)      { subject.primary_key_name }
          let(:entities) { [] }
          let(:options)  { {} }
          let(:keys)     { subject.map_entities_to_keys(*entities, **options) }

          example_class 'Spec::Entity' do |klass|
            klass.define_method(:initialize) do |**attributes|
              attributes.each do |key, value|
                instance_variable_set(:"@#{key}", value)
              end
            end

            klass.attr_reader :id
          end

          describe 'with no entities' do
            let(:entities) { [] }

            it { expect(keys).to be == [] }
          end

          describe 'with one nil entity' do
            let(:entities) { [nil] }

            it { expect(keys).to be == [] }
          end

          describe 'with one invalid entity' do
            let(:entities) { [Object.new.freeze] }
            let(:error_message) do
              "undefined method :[] or :#{key} for #{entities.first.inspect}"
            end

            it 'should raise an exception' do
              expect { association.map_entities_to_keys(*entities) }
                .to raise_error ArgumentError, error_message
            end
          end

          describe 'with one Integer' do
            let(:entities) { [0] }
            let(:error_message) do
              "undefined method :[] or :#{key} for #{entities.first.inspect}"
            end

            it 'should raise an exception' do
              expect { association.map_entities_to_keys(*entities) }
                .to raise_error ArgumentError, error_message
            end

            describe 'with strict: false' do
              it 'should raise an exception' do
                expect(
                  association.map_entities_to_keys(*entities, strict: false)
                )
                  .to be == entities
              end
            end

            context 'when initialized with primary_key_type: String' do
              let(:constructor_options) do
                super().merge(primary_key_type: String)
              end

              describe 'with strict: false' do
                it 'should raise an exception' do
                  expect do
                    association.map_entities_to_keys(*entities, strict: false)
                  end
                    .to raise_error ArgumentError, error_message
                end
              end
            end
          end

          describe 'with one String' do
            let(:entities) { %w[0] }
            let(:error_message) do
              "undefined method :[] or :#{key} for #{entities.first.inspect}"
            end

            it 'should raise an exception' do
              expect { association.map_entities_to_keys(*entities) }
                .to raise_error ArgumentError, error_message
            end

            describe 'with strict: false' do
              it 'should raise an exception' do
                expect do
                  association.map_entities_to_keys(*entities, strict: false)
                end
                  .to raise_error ArgumentError, error_message
              end
            end

            context 'when initialized with primary_key_type: String' do
              let(:constructor_options) do
                super().merge(primary_key_type: String)
              end

              describe 'with strict: false' do
                it 'should raise an exception' do
                  expect(
                    association.map_entities_to_keys(*entities, strict: false)
                  )
                    .to be == entities
                end
              end
            end
          end

          describe 'with one entity that responds to #[] and key: nil' do
            let(:entities) { [{ key => nil }] }

            it { expect(keys).to be == [] }

            describe 'with allow_nil: true' do
              let(:options) { super().merge(allow_nil: true) }

              it { expect(keys).to be == [nil] }
            end
          end

          describe 'with one entity that responds to #[] and key: value' do
            let(:entities) { [{ key => 0 }] }

            it { expect(keys).to be == [0] }
          end

          describe 'with one entity that responds to #id and key: nil' do
            let(:entities) { [Spec::Entity.new(key => nil)] }

            it { expect(keys).to be == [] }

            describe 'with allow_nil: true' do
              let(:options) { super().merge(allow_nil: true) }

              it { expect(keys).to be == [nil] }
            end
          end

          describe 'with one entity that responds to #id and key: value' do
            let(:entities) { [Spec::Entity.new(key => 0)] }

            it { expect(keys).to be == [0] }
          end

          describe 'with multiple entities' do
            let(:entities) do
              [
                Spec::Entity.new(key => 0),
                Spec::Entity.new(key => 1),
                Spec::Entity.new(key => 2)
              ]
            end

            it { expect(keys).to be == [0, 1, 2] }
          end

          describe 'with multiple entities including nil' do
            let(:entities) do
              [
                Spec::Entity.new(key => 0),
                nil,
                Spec::Entity.new(key => 1),
                nil,
                Spec::Entity.new(key => 2)
              ]
            end

            it { expect(keys).to be == [0, 1, 2] }
          end

          describe 'with multiple entities including nil ids' do
            let(:entities) do
              [
                Spec::Entity.new(key => 0),
                Spec::Entity.new(key => nil),
                Spec::Entity.new(key => 1),
                Spec::Entity.new(key => nil),
                Spec::Entity.new(key => 2)
              ]
            end

            it { expect(keys).to be == [0, 1, 2] }

            describe 'with allow_nil: true' do
              let(:options) { super().merge(allow_nil: true) }

              it { expect(keys).to be == [0, nil, 1, 2] }
            end
          end

          describe 'with multiple entities including duplicate ids' do
            let(:entities) do
              [
                Spec::Entity.new(key => 0),
                Spec::Entity.new(key => 1),
                Spec::Entity.new(key => 0),
                Spec::Entity.new(key => 1),
                Spec::Entity.new(key => 2)
              ]
            end

            it { expect(keys).to be == [0, 1, 2] }

            describe 'with deduplicate: false' do
              let(:options) { super().merge(deduplicate: false) }

              it { expect(keys).to be == [0, 1, 0, 1, 2] }
            end
          end

          describe 'with multiple Integers' do
            let(:entities) { [0, 1, 2] }
            let(:error_message) do
              "undefined method :[] or :#{key} for #{entities.first.inspect}"
            end

            it 'should raise an exception' do
              expect { association.map_entities_to_keys(*entities) }
                .to raise_error ArgumentError, error_message
            end

            describe 'with strict: false' do
              it 'should raise an exception' do
                expect(
                  association.map_entities_to_keys(*entities, strict: false)
                )
                  .to be == entities
              end
            end

            context 'when initialized with primary_key_type: String' do
              let(:constructor_options) do
                super().merge(primary_key_type: String)
              end

              describe 'with strict: false' do
                it 'should raise an exception' do
                  expect do
                    association.map_entities_to_keys(*entities, strict: false)
                  end
                    .to raise_error ArgumentError, error_message
                end
              end
            end
          end

          describe 'with multiple Strings' do
            let(:entities) { %w[0 1 2] }
            let(:error_message) do
              "undefined method :[] or :#{key} for #{entities.first.inspect}"
            end

            it 'should raise an exception' do
              expect { association.map_entities_to_keys(*entities) }
                .to raise_error ArgumentError, error_message
            end

            describe 'with strict: false' do
              it 'should raise an exception' do
                expect do
                  association.map_entities_to_keys(*entities, strict: false)
                end
                  .to raise_error ArgumentError, error_message
              end
            end

            context 'when initialized with primary_key_type: String' do
              let(:constructor_options) do
                super().merge(primary_key_type: String)
              end

              describe 'with strict: false' do
                it 'should raise an exception' do
                  expect(
                    association.map_entities_to_keys(*entities, strict: false)
                  )
                    .to be == entities
                end
              end
            end
          end
        end

        describe '#primary_key_query?' do
          it { expect(subject.primary_key_query?).to be false }
        end

        describe '#query_key_name' do
          context 'when the foreign key name is blank' do
            let(:error_message) do
              "foreign key name can't be blank"
            end

            it 'should raise an exception' do
              expect { association.query_key_name }
                .to raise_error ArgumentError, error_message
            end
          end

          context 'when initialized with foreign_key_name: a String' do
            let(:foreign_key_name) { 'writer_id' }
            let(:constructor_options) do
              super().merge(foreign_key_name: foreign_key_name)
            end

            it { expect(subject.query_key_name).to be == 'writer_id' }
          end

          context 'when initialized with foreign_key_name: a String' do
            let(:foreign_key_name) { :writer_id }
            let(:constructor_options) do
              super().merge(foreign_key_name: foreign_key_name)
            end

            it { expect(subject.query_key_name).to be == 'writer_id' }
          end

          context 'when initialized with inverse: value' do
            let(:inverse) { described_class.new(name: 'authors') }
            let(:constructor_options) do
              super().merge(inverse: inverse)
            end

            it { expect(subject.query_key_name).to be == 'author_id' }

            context 'when initialized with foreign_key_name: a String' do
              let(:foreign_key_name) { 'writer_id' }
              let(:constructor_options) do
                super().merge(foreign_key_name: foreign_key_name)
              end

              it { expect(subject.query_key_name).to be == 'writer_id' }
            end

            context 'when initialized with foreign_key_name: a String' do
              let(:foreign_key_name) { :writer_id }
              let(:constructor_options) do
                super().merge(foreign_key_name: foreign_key_name)
              end

              it { expect(subject.query_key_name).to be == 'writer_id' }
            end

            context 'when initialized with inverse_name: value' do
              let(:inverse_name) { 'writers' }
              let(:constructor_options) do
                super().merge(inverse_name: inverse_name)
              end

              it { expect(subject.query_key_name).to be == 'author_id' }
            end

            context 'when initialized with singular_inverse_name: value' do
              let(:singular_inverse_name) { 'writer' }
              let(:constructor_options) do
                super().merge(singular_inverse_name: singular_inverse_name)
              end

              it { expect(subject.query_key_name).to be == 'writer_id' }
            end
          end

          context 'when initialized with inverse_name: value' do
            let(:inverse_name) { 'authors' }
            let(:constructor_options) do
              super().merge(inverse_name: inverse_name)
            end

            it { expect(subject.query_key_name).to be == 'author_id' }

            context 'when initialized with foreign_key_name: a String' do
              let(:foreign_key_name) { 'writer_id' }
              let(:constructor_options) do
                super().merge(foreign_key_name: foreign_key_name)
              end

              it { expect(subject.query_key_name).to be == 'writer_id' }
            end

            context 'when initialized with foreign_key_name: a String' do
              let(:foreign_key_name) { :writer_id }
              let(:constructor_options) do
                super().merge(foreign_key_name: foreign_key_name)
              end

              it { expect(subject.query_key_name).to be == 'writer_id' }
            end
          end

          context 'when initialized with singular_inverse_name: value' do
            let(:singular_inverse_name) { 'author' }
            let(:constructor_options) do
              super().merge(singular_inverse_name: singular_inverse_name)
            end

            it { expect(subject.query_key_name).to be == 'author_id' }

            context 'when initialized with foreign_key_name: a String' do
              let(:foreign_key_name) { 'writer_id' }
              let(:constructor_options) do
                super().merge(foreign_key_name: foreign_key_name)
              end

              it { expect(subject.query_key_name).to be == 'writer_id' }
            end

            context 'when initialized with foreign_key_name: a String' do
              let(:foreign_key_name) { :writer_id }
              let(:constructor_options) do
                super().merge(foreign_key_name: foreign_key_name)
              end

              it { expect(subject.query_key_name).to be == 'writer_id' }
            end
          end

          context 'with a copy with assigned inverse' do
            subject do
              super().tap(&:foreign_key_name).with_inverse(new_inverse)
            end

            let(:new_inverse) { described_class.new(name: 'chapters') }

            it { expect(subject.query_key_name).to be == 'chapter_id' }

            context 'when initialized with foreign_key_name: a String' do
              let(:foreign_key_name) { 'writer_id' }
              let(:constructor_options) do
                super().merge(foreign_key_name: foreign_key_name)
              end

              it { expect(subject.query_key_name).to be == 'writer_id' }
            end

            context 'when initialized with foreign_key_name: a String' do
              let(:foreign_key_name) { :writer_id }
              let(:constructor_options) do
                super().merge(foreign_key_name: foreign_key_name)
              end

              it { expect(subject.query_key_name).to be == 'writer_id' }
            end

            context 'when initialized with inverse: value' do
              let(:inverse) { described_class.new(name: 'authors') }
              let(:constructor_options) do
                super().merge(inverse: inverse)
              end

              it { expect(subject.query_key_name).to be == 'chapter_id' }
            end

            context 'when initialized with inverse_name: value' do
              let(:inverse_name) { 'authors' }
              let(:constructor_options) do
                super().merge(inverse_name: inverse_name)
              end

              it { expect(subject.query_key_name).to be == 'chapter_id' }
            end

            context 'when initialized with singular_inverse_name: value' do
              let(:singular_inverse_name) { 'author' }
              let(:constructor_options) do
                super().merge(singular_inverse_name: singular_inverse_name)
              end

              it { expect(subject.query_key_name).to be == 'author_id' }
            end
          end
        end
      end
    end
  end
end
