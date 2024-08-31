# frozen_string_literal: true

require 'cuprum/rspec/deferred/parameter_validation_examples'

require 'cuprum/collections/rspec/contracts'

module Cuprum::Collections::RSpec::Contracts
  # Contracts for asserting on Command objects.
  module CommandContracts
    include Cuprum::RSpec::Deferred::ParameterValidationExamples

    # Contract validating the behavior of an AssignOne command implementation.
    module ShouldBeAnAssignOneCommandContract
      extend RSpec::SleepingKingStudios::Contract

      # @!method apply(example_group, allow_extra_attributes:)
      #   Adds the contract to the example group.
      #
      #   @param example_group [RSpec::Core::ExampleGroup] the example group to
      #     which the contract is applied.
      #   @param allow_extra_attributes [Boolean] if false, the command should
      #     fail if given attributes not defined for the entity.
      contract do |allow_extra_attributes:|
        describe '#call' do
          shared_examples 'should assign the attributes' do
            it { expect(result).to be_a_passing_result }

            it { expect(result.value).to be_a entity.class }

            it { expect(result.value).to be == expected_value }
          end

          let(:attributes) { {} }
          let(:result) do
            command.call(attributes:, entity:)
          end
          let(:expected_attributes) do
            initial_attributes.merge(attributes)
          end
          let(:expected_value) do
            defined?(super()) ? super() : expected_attributes
          end

          def call_command
            command.call(attributes:, entity:)
          end

          include_contract 'should validate the attributes'

          if defined_deferred_examples? 'should validate the entity'
            include_deferred 'should validate the entity'
          else
            # :nocov:
            pending \
              'the command should validate the entity parameter, but entity ' \
              'validation is not defined - implement a "should validate the ' \
              'entity" deferred example group to resolve this warning'
            # :nocov:
          end

          describe 'with an empty attributes hash' do
            let(:attributes) { {} }

            include_examples 'should assign the attributes'
          end

          describe 'with an attributes hash with partial attributes' do
            let(:attributes) { { title: 'Gideon the Ninth' } }

            include_examples 'should assign the attributes'
          end

          describe 'with an attributes hash with full attributes' do
            let(:attributes) do
              {
                title:    'Gideon the Ninth',
                author:   'Tamsyn Muir',
                series:   'The Locked Tomb',
                category: 'Horror'
              }
            end

            include_examples 'should assign the attributes'
          end

          describe 'with an attributes hash with extra attributes' do
            let(:attributes) do
              {
                title:     'The Book of Lost Tales',
                audiobook: true
              }
            end

            if allow_extra_attributes
              include_examples 'should assign the attributes'
            else
              # :nocov:
              let(:valid_attributes) do
                defined?(super()) ? super() : expected_attributes.keys
              end
              let(:expected_error) do
                Cuprum::Collections::Errors::ExtraAttributes.new(
                  entity_class:     entity.class,
                  extra_attributes: %w[audiobook],
                  valid_attributes:
                )
              end

              it 'should return a failing result' do
                expect(result).to be_a_failing_result.with_error(expected_error)
              end
              # :nocov:
            end
          end

          context 'when the entity has existing attributes' do
            let(:initial_attributes) do
              # :nocov:
              if defined?(super())
                super().merge(fixtures_data.first)
              else
                fixtures_data.first
              end
              # :nocov:
            end

            describe 'with an empty attributes hash' do
              let(:attributes) { {} }

              include_examples 'should assign the attributes'
            end

            describe 'with an attributes hash with partial attributes' do
              let(:attributes) { { title: 'Gideon the Ninth' } }

              include_examples 'should assign the attributes'
            end

            describe 'with an attributes hash with full attributes' do
              let(:attributes) do
                {
                  title:    'Gideon the Ninth',
                  author:   'Tamsyn Muir',
                  series:   'The Locked Tomb',
                  category: 'Horror'
                }
              end

              include_examples 'should assign the attributes'
            end

            describe 'with an attributes hash with extra attributes' do
              let(:attributes) do
                {
                  title:     'The Book of Lost Tales',
                  audiobook: true
                }
              end

              if allow_extra_attributes
                include_examples 'should assign the attributes'
              else
                # :nocov:
                let(:valid_attributes) do
                  defined?(super()) ? super() : expected_attributes.keys
                end
                let(:expected_error) do
                  Cuprum::Collections::Errors::ExtraAttributes.new(
                    entity_class:     entity.class,
                    extra_attributes: %w[audiobook],
                    valid_attributes:
                  )
                end

                it 'should return a failing result' do
                  expect(result)
                    .to be_a_failing_result
                    .with_error(expected_error)
                end
                # :nocov:
              end
            end
          end
        end
      end
    end

    # Contract validating the behavior of a Build command implementation.
    module ShouldBeABuildOneCommandContract
      extend RSpec::SleepingKingStudios::Contract

      # @!method apply(example_group, allow_extra_attributes:)
      #   Adds the contract to the example group.
      #
      #   @param example_group [RSpec::Core::ExampleGroup] the example group to
      #     which the contract is applied.
      #   @param allow_extra_attributes [Boolean] if false, the command should
      #     fail if given attributes not defined for the entity.
      contract do |allow_extra_attributes:|
        include Stannum::RSpec::Matchers

        describe '#call' do
          shared_examples 'should build the entity' do
            it { expect(result).to be_a_passing_result }

            it { expect(result.value).to be == expected_value }
          end

          let(:attributes) { {} }
          let(:result)     { command.call(attributes:) }
          let(:expected_attributes) do
            attributes
          end
          let(:expected_value) do
            defined?(super()) ? super() : attributes
          end

          def call_command
            command.call(attributes:)
          end

          include_contract 'should validate the attributes'

          describe 'with an empty attributes hash' do
            let(:attributes) { {} }

            include_examples 'should build the entity'
          end

          describe 'with an attributes hash with partial attributes' do
            let(:attributes) { { title: 'Gideon the Ninth' } }

            include_examples 'should build the entity'
          end

          describe 'with an attributes hash with full attributes' do
            let(:attributes) do
              {
                title:    'Gideon the Ninth',
                author:   'Tamsyn Muir',
                series:   'The Locked Tomb',
                category: 'Horror'
              }
            end

            include_examples 'should build the entity'
          end

          describe 'with an attributes hash with extra attributes' do
            let(:attributes) do
              {
                title:     'The Book of Lost Tales',
                audiobook: true
              }
            end

            if allow_extra_attributes
              include_examples 'should build the entity'
            else
              # :nocov:
              let(:valid_attributes) do
                defined?(super()) ? super() : expected_attributes.keys
              end
              let(:expected_error) do
                Cuprum::Collections::Errors::ExtraAttributes.new(
                  entity_class:     entity_type,
                  extra_attributes: %w[audiobook],
                  valid_attributes:
                )
              end

              it 'should return a failing result' do
                expect(result).to be_a_failing_result.with_error(expected_error)
              end
              # :nocov:
            end
          end
        end
      end
    end

    # Contract validating the behavior of a DestroyOne command implementation.
    module ShouldBeADestroyOneCommandContract
      extend RSpec::SleepingKingStudios::Contract

      # @!method apply(example_group)
      #   Adds the contract to the example group.
      #
      #   @param example_group [RSpec::Core::ExampleGroup] the example group to
      #     which the contract is applied.
      contract do
        describe '#call' do
          let(:query) { collection.query }
          let(:mapped_data) do
            defined?(super()) ? super() : data
          end
          let(:invalid_primary_key_value) do
            defined?(super()) ? super() : 100
          end
          let(:valid_primary_key_value) do
            defined?(super()) ? super() : 0
          end

          def call_command
            command.call(primary_key:)
          end

          include_contract 'should validate the primary key'

          describe 'with an invalid primary key' do
            let(:primary_key) { invalid_primary_key_value }
            let(:expected_error) do
              Cuprum::Collections::Errors::NotFound.new(
                attribute_name:  collection.primary_key_name,
                attribute_value: primary_key,
                collection_name: collection.name,
                primary_key:     true
              )
            end

            it 'should return a failing result' do
              expect(command.call(primary_key:))
                .to be_a_failing_result
                .with_error(expected_error)
            end

            it 'should not remove an entity from the collection' do
              expect { command.call(primary_key:) }
                .not_to(change { query.reset.count })
            end
          end

          context 'when the collection has many items' do
            let(:data) { fixtures_data }
            let(:matching_data) do
              mapped_data.find do |item|
                item[collection.primary_key_name.to_s] == primary_key
              end
            end
            let!(:expected_data) do
              defined?(super()) ? super() : matching_data
            end

            describe 'with an invalid primary key' do
              let(:primary_key) { invalid_primary_key_value }
              let(:expected_error) do
                Cuprum::Collections::Errors::NotFound.new(
                  attribute_name:  collection.primary_key_name,
                  attribute_value: primary_key,
                  collection_name: collection.name,
                  primary_key:     true
                )
              end

              it 'should return a failing result' do
                expect(command.call(primary_key:))
                  .to be_a_failing_result
                  .with_error(expected_error)
              end

              it 'should not remove an entity from the collection' do
                expect { command.call(primary_key:) }
                  .not_to(change { query.reset.count })
              end
            end

            describe 'with a valid primary key' do
              let(:primary_key) { valid_primary_key_value }

              it 'should return a passing result' do
                expect(command.call(primary_key:))
                  .to be_a_passing_result
                  .with_value(expected_data)
              end

              it 'should remove an entity from the collection' do
                expect { command.call(primary_key:) }
                  .to(
                    change { query.reset.count }.by(-1)
                  )
              end

              it 'should remove the entity from the collection' do
                command.call(primary_key:)

                expect(
                  query.map { |item| item[collection.primary_key_name.to_s] }
                )
                  .not_to include primary_key
              end
            end
          end
        end
      end
    end

    # Contract validating the behavior of a FindMany command implementation.
    module ShouldBeAFindManyCommandContract
      extend RSpec::SleepingKingStudios::Contract

      # @!method apply(example_group)
      #   Adds the contract to the example group.
      #
      #   @param example_group [RSpec::Core::ExampleGroup] the example group to
      #     which the contract is applied.
      contract do
        describe '#call' do
          let(:mapped_data) do
            defined?(super()) ? super() : data
          end
          let(:primary_key_name) { defined?(super()) ? super() : 'id' }
          let(:primary_key_type) { defined?(super()) ? super() : Integer }
          let(:invalid_primary_key_values) do
            defined?(super()) ? super() : [100, 101, 102]
          end
          let(:valid_primary_key_values) do
            defined?(super()) ? super() : [0, 1, 2]
          end
          let(:primary_keys) { [] }
          let(:options)      { {} }

          def call_command
            command.call(primary_keys:, **options)
          end

          include_contract 'should validate the primary keys'

          describe 'with an invalid allow_partial value' do
            let(:options) { super().merge(allow_partial: Object.new.freeze) }

            include_deferred 'should validate the parameter',
              :allow_partial,
              'sleeping_king_studios.tools.assertions.boolean'
          end

          describe 'with an invalid envelope value' do
            let(:options) { super().merge(envelope: Object.new.freeze) }

            include_deferred 'should validate the parameter',
              :envelope,
              'sleeping_king_studios.tools.assertions.boolean'
          end

          describe 'with an empty array of primary keys' do
            let(:primary_keys)  { [] }
            let(:expected_data) { [] }

            it 'should return a passing result' do
              expect(command.call(primary_keys:))
                .to be_a_passing_result
                .with_value(expected_data)
            end
          end

          describe 'with an array of invalid primary keys' do
            let(:primary_keys) { invalid_primary_key_values }
            let(:expected_error) do
              Cuprum::Errors::MultipleErrors.new(
                errors: primary_keys.map do |primary_key|
                  Cuprum::Collections::Errors::NotFound.new(
                    attribute_name:  collection.primary_key_name,
                    attribute_value: primary_key,
                    collection_name: collection.name,
                    primary_key:     true
                  )
                end
              )
            end

            it 'should return a failing result' do
              expect(command.call(primary_keys:))
                .to be_a_failing_result
                .with_error(expected_error)
            end
          end

          context 'when the collection has many items' do
            let(:data) { fixtures_data }
            let(:matching_data) do
              primary_keys
                .map do |key|
                  mapped_data.find { |item| item[primary_key_name.to_s] == key }
                end
            end
            let(:expected_data) do
              defined?(super()) ? super() : matching_data
            end

            describe 'with an empty array of primary keys' do
              let(:primary_keys)  { [] }
              let(:expected_data) { [] }

              it 'should return a passing result' do
                expect(command.call(primary_keys:))
                  .to be_a_passing_result
                  .with_value(expected_data)
              end
            end

            describe 'with an array of invalid primary keys' do
              let(:primary_keys) { invalid_primary_key_values }
              let(:expected_error) do
                Cuprum::Errors::MultipleErrors.new(
                  errors: primary_keys.map do |primary_key|
                    Cuprum::Collections::Errors::NotFound.new(
                      attribute_name:  collection.primary_key_name,
                      attribute_value: primary_key,
                      collection_name: collection.name,
                      primary_key:     true
                    )
                  end
                )
              end

              it 'should return a failing result' do
                expect(command.call(primary_keys:))
                  .to be_a_failing_result
                  .with_error(expected_error)
              end
            end

            describe 'with a partially valid array of primary keys' do
              let(:primary_keys) do
                invalid_primary_key_values + valid_primary_key_values
              end
              let(:expected_error) do
                Cuprum::Errors::MultipleErrors.new(
                  errors: primary_keys.map do |primary_key|
                    unless invalid_primary_key_values.include?(primary_key)
                      next nil
                    end

                    Cuprum::Collections::Errors::NotFound.new(
                      attribute_name:  collection.primary_key_name,
                      attribute_value: primary_key,
                      collection_name: collection.name,
                      primary_key:     true
                    )
                  end
                )
              end

              it 'should return a failing result' do
                expect(command.call(primary_keys:))
                  .to be_a_failing_result
                  .with_error(expected_error)
              end
            end

            describe 'with a valid array of primary keys' do
              let(:primary_keys) { valid_primary_key_values }

              it 'should return a passing result' do
                expect(command.call(primary_keys:))
                  .to be_a_passing_result
                  .with_value(expected_data)
              end

              describe 'with an ordered array of primary keys' do
                let(:primary_keys) { valid_primary_key_values.reverse }

                it 'should return a passing result' do
                  expect(command.call(primary_keys:))
                    .to be_a_passing_result
                    .with_value(expected_data)
                end
              end
            end

            describe 'with allow_partial: true' do
              describe 'with an array of invalid primary keys' do
                let(:primary_keys) { invalid_primary_key_values }
                let(:expected_error) do
                  Cuprum::Errors::MultipleErrors.new(
                    errors: invalid_primary_key_values.map do |primary_key|
                      Cuprum::Collections::Errors::NotFound.new(
                        attribute_name:  collection.primary_key_name,
                        attribute_value: primary_key,
                        collection_name: collection.name,
                        primary_key:     true
                      )
                    end
                  )
                end

                it 'should return a failing result' do
                  expect(command.call(primary_keys:))
                    .to be_a_failing_result
                    .with_error(expected_error)
                end
              end

              describe 'with a partially valid array of primary keys' do
                let(:primary_keys) do
                  invalid_primary_key_values + valid_primary_key_values
                end
                let(:expected_error) do
                  Cuprum::Errors::MultipleErrors.new(
                    errors: primary_keys.map do |primary_key|
                      unless invalid_primary_key_values.include?(primary_key)
                        next nil
                      end

                      Cuprum::Collections::Errors::NotFound.new(
                        attribute_name:  collection.primary_key_name,
                        attribute_value: primary_key,
                        collection_name: collection.name,
                        primary_key:     true
                      )
                    end
                  )
                end

                it 'should return a passing result' do
                  expect(
                    command.call(
                      primary_keys:,
                      allow_partial: true
                    )
                  )
                    .to be_a_passing_result
                    .with_value(expected_data)
                    .and_error(expected_error)
                end
              end

              describe 'with a valid array of primary keys' do
                let(:primary_keys) { valid_primary_key_values }

                it 'should return a passing result' do
                  expect(
                    command.call(
                      primary_keys:,
                      allow_partial: true
                    )
                  )
                    .to be_a_passing_result
                    .with_value(expected_data)
                end

                describe 'with an ordered array of primary keys' do
                  let(:primary_keys) { valid_primary_key_values.reverse }

                  it 'should return a passing result' do
                    expect(
                      command.call(
                        primary_keys:,
                        allow_partial: true
                      )
                    )
                      .to be_a_passing_result
                      .with_value(expected_data)
                  end
                end
              end
            end

            describe 'with envelope: true' do
              describe 'with an empty array of primary keys' do
                let(:primary_keys)  { [] }
                let(:expected_data) { [] }

                it 'should return a passing result' do
                  expect(
                    command.call(primary_keys:, envelope: true)
                  )
                    .to be_a_passing_result
                    .with_value({ collection.name => expected_data })
                end
              end

              describe 'with a valid array of primary keys' do
                let(:primary_keys) { valid_primary_key_values }

                it 'should return a passing result' do
                  expect(
                    command.call(primary_keys:, envelope: true)
                  )
                    .to be_a_passing_result
                    .with_value({ collection.name => expected_data })
                end

                describe 'with an ordered array of primary keys' do
                  let(:primary_keys) { valid_primary_key_values.reverse }

                  it 'should return a passing result' do
                    expect(
                      command.call(primary_keys:, envelope: true)
                    )
                      .to be_a_passing_result
                      .with_value({ collection.name => expected_data })
                  end
                end
              end
            end
          end
        end
      end
    end

    # Contract validating the behavior of a FindMatching command implementation.
    module ShouldBeAFindMatchingCommandContract
      extend RSpec::SleepingKingStudios::Contract

      # @!method apply(example_group)
      #   Adds the contract to the example group.
      #
      #   @param example_group [RSpec::Core::ExampleGroup] the example group to
      #     which the contract is applied.
      contract do
        include Stannum::RSpec::Matchers
        include Cuprum::Collections::RSpec::Contracts::QueryContracts

        describe '#call' do
          shared_examples 'should return the matching items' do
            it { expect(result).to be_a_passing_result }

            it { expect(result.value).to be_a Enumerator }

            it { expect(result.value.to_a).to be == expected_data }
          end

          shared_examples 'should return the wrapped items' do
            it { expect(result).to be_a_passing_result }

            it { expect(result.value).to be_a Hash }

            it { expect(result.value.keys).to be == [collection.name] }

            it { expect(result.value[collection.name]).to be == expected_data }
          end

          let(:filter) { nil }
          let(:limit)  { nil }
          let(:offset) { nil }
          let(:order)  { nil }
          let(:options) do
            opts = {}

            opts[:limit]  = limit  if limit
            opts[:offset] = offset if offset
            opts[:order]  = order  if order
            opts[:where]  = filter unless filter.nil? || filter.is_a?(Proc)

            opts
          end
          let(:block)  { filter.is_a?(Proc) ? filter : nil }
          let(:result) { command.call(**options, &block) }
          let(:data)   { [] }
          let(:filtered_data) do
            defined?(super()) ? super() : data
          end
          let(:matching_data) do
            defined?(super()) ? super() : filtered_data
          end
          let(:expected_data) do
            defined?(super()) ? super() : matching_data
          end

          def call_command
            command.call(**options, &block)
          end

          describe 'with an invalid envelope value' do
            let(:options) { super().merge(envelope: Object.new.freeze) }

            include_deferred 'should validate the parameter',
              :envelope,
              'sleeping_king_studios.tools.assertions.boolean'
          end

          describe 'with an invalid limit value' do
            let(:options) { super().merge(limit: Object.new.freeze) }

            include_deferred 'should validate the parameter',
              :limit,
              'sleeping_king_studios.tools.assertions.instance_of',
              expected: Integer
          end

          describe 'with an invalid offset value' do
            let(:options) { super().merge(offset: Object.new.freeze) }

            include_deferred 'should validate the parameter',
              :offset,
              'sleeping_king_studios.tools.assertions.instance_of',
              expected: Integer
          end

          describe 'with an invalid order value' do
            let(:options) { super().merge(order: Object.new.freeze) }

            include_deferred 'should validate the parameter',
              :order,
              message: 'order is not a valid sort order'
          end

          describe 'with an invalid where value' do
            let(:options) { super().merge(where: Object.new.freeze) }

            include_deferred 'should validate the parameter',
              :where,
              message: 'where is not a scope or query hash'
          end

          describe 'with an invalid filter block' do
            let(:block) { -> {} }
            let(:expected_error) do
              an_instance_of(Cuprum::Collections::Errors::InvalidQuery)
            end

            it 'should return a failing result' do
              expect(result).to be_a_failing_result.with_error(expected_error)
            end
          end

          include_examples 'should return the matching items'

          describe 'with envelope: true' do
            let(:options) { super().merge(envelope: true) }

            include_examples 'should return the wrapped items'
          end

          context 'when the collection has many items' do
            let(:data) { fixtures_data }

            include_contract 'should query the collection' do
              include_examples 'should return the matching items'

              describe 'with envelope: true' do
                let(:options) { super().merge(envelope: true) }

                include_examples 'should return the wrapped items'
              end
            end
          end
        end
      end
    end

    # Contract validating the behavior of a FindOne command implementation.
    module ShouldBeAFindOneCommandContract
      extend RSpec::SleepingKingStudios::Contract

      # @!method apply(example_group)
      #   Adds the contract to the example group.
      #
      #   @param example_group [RSpec::Core::ExampleGroup] the example group to
      #     which the contract is applied.
      contract do
        describe '#call' do
          let(:mapped_data) do
            defined?(super()) ? super() : data
          end
          let(:primary_key_name) { defined?(super()) ? super() : 'id' }
          let(:primary_key_type) { defined?(super()) ? super() : Integer }
          let(:invalid_primary_key_value) do
            defined?(super()) ? super() : 100
          end
          let(:valid_primary_key_value) do
            defined?(super()) ? super() : 0
          end
          let(:primary_key) { valid_primary_key_value }
          let(:options)     { {} }

          def call_command
            command.call(primary_key:, **options)
          end

          include_contract 'should validate the primary key'

          describe 'with an invalid envelope value' do
            let(:options) { super().merge(envelope: Object.new.freeze) }

            include_deferred 'should validate the parameter',
              :envelope,
              'sleeping_king_studios.tools.assertions.boolean'
          end

          describe 'with an invalid primary key' do
            let(:primary_key) { invalid_primary_key_value }
            let(:expected_error) do
              Cuprum::Collections::Errors::NotFound.new(
                attribute_name:  collection.primary_key_name,
                attribute_value: primary_key,
                collection_name: collection.name,
                primary_key:     true
              )
            end

            it 'should return a failing result' do
              expect(command.call(primary_key:))
                .to be_a_failing_result
                .with_error(expected_error)
            end
          end

          context 'when the collection has many items' do
            let(:data) { fixtures_data }
            let(:matching_data) do
              mapped_data
                .find { |item| item[primary_key_name.to_s] == primary_key }
            end
            let(:expected_data) do
              defined?(super()) ? super() : matching_data
            end

            describe 'with an invalid primary key' do
              let(:primary_key) { invalid_primary_key_value }
              let(:expected_error) do
                Cuprum::Collections::Errors::NotFound.new(
                  attribute_name:  collection.primary_key_name,
                  attribute_value: primary_key,
                  collection_name: collection.name,
                  primary_key:     true
                )
              end

              it 'should return a failing result' do
                expect(command.call(primary_key:))
                  .to be_a_failing_result
                  .with_error(expected_error)
              end
            end

            describe 'with a valid primary key' do
              let(:primary_key) { valid_primary_key_value }

              it 'should return a passing result' do
                expect(command.call(primary_key:))
                  .to be_a_passing_result
                  .with_value(expected_data)
              end
            end

            describe 'with envelope: true' do
              let(:member_name) { collection.singular_name }

              describe 'with a valid primary key' do
                let(:primary_key) { valid_primary_key_value }

                it 'should return a passing result' do
                  expect(command.call(primary_key:, envelope: true))
                    .to be_a_passing_result
                    .with_value({ member_name => expected_data })
                end
              end
            end
          end
        end
      end
    end

    # Contract validating the behavior of an InsertOne command implementation.
    module ShouldBeAnInsertOneCommandContract
      extend RSpec::SleepingKingStudios::Contract

      # @!method apply(example_group)
      #   Adds the contract to the example group.
      #
      #   @param example_group [RSpec::Core::ExampleGroup] the example group to
      #     which the contract is applied.
      contract do
        describe '#call' do
          let(:matching_data) { attributes }
          let(:expected_data) do
            defined?(super()) ? super() : matching_data
          end
          let(:primary_key_name) do
            defined?(super()) ? super() : 'id'
          end
          let(:primary_key_type) do
            defined?(super()) ? super() : Integer
          end
          let(:scoped) do
            key    = primary_key_name
            value  = entity[primary_key_name.to_s]

            collection.query.where { { key => value } }
          end

          def call_command
            command.call(entity:)
          end

          if defined_deferred_examples? 'should validate the entity'
            include_deferred 'should validate the entity'
          else
            # :nocov:
            pending \
              'the command should validate the entity parameter, but entity ' \
              'validation is not defined - implement a "should validate the ' \
              'entity" deferred example group to resolve this warning'
            # :nocov:
          end

          context 'when the item does not exist in the collection' do
            it 'should return a passing result' do
              expect(command.call(entity:))
                .to be_a_passing_result
                .with_value(be == expected_data)
            end

            it 'should append an item to the collection' do
              expect { command.call(entity:) }
                .to(
                  change { collection.query.count }
                  .by(1)
                )
            end

            it 'should add the entity to the collection' do
              expect { command.call(entity:) }
                .to change(scoped, :exists?)
                .to be true
            end

            it 'should set the attributes' do
              command.call(entity:)

              expect(scoped.to_a.first).to be == expected_data
            end
          end

          context 'when the item exists in the collection' do
            let(:data) { fixtures_data }
            let(:expected_error) do
              Cuprum::Collections::Errors::AlreadyExists.new(
                attribute_name:  collection.primary_key_name,
                attribute_value: attributes.fetch(
                  primary_key_name.to_s,
                  attributes[primary_key_name.intern]
                ),
                collection_name: collection.name,
                primary_key:     true
              )
            end

            it 'should return a failing result' do
              expect(command.call(entity:))
                .to be_a_failing_result
                .with_error(expected_error)
            end

            it 'should not append an item to the collection' do
              expect { command.call(entity:) }
                .not_to(change { collection.query.count })
            end
          end
        end
      end
    end

    # Contract validating the behavior of an UpdateOne command implementation.
    module ShouldBeAnUpdateOneCommandContract
      extend RSpec::SleepingKingStudios::Contract

      # @!method apply(example_group)
      #   Adds the contract to the example group.
      #
      #   @param example_group [RSpec::Core::ExampleGroup] the example group to
      #     which the contract is applied.
      contract do
        describe '#call' do
          let(:mapped_data) do
            defined?(super()) ? super() : data
          end
          let(:matching_data) { attributes }
          let(:expected_data) do
            defined?(super()) ? super() : matching_data
          end
          let(:primary_key_name) do
            defined?(super()) ? super() : 'id'
          end
          let(:scoped) do
            key    = primary_key_name
            value  = entity[primary_key_name.to_s]

            collection.query.where { { key => value } }
          end

          def call_command
            command.call(entity:)
          end

          if defined_deferred_examples? 'should validate the entity'
            include_deferred 'should validate the entity'
          else
            # :nocov:
            pending \
              'the command should validate the entity parameter, but entity ' \
              'validation is not defined - implement a "should validate the ' \
              'entity" deferred example group to resolve this warning'
            # :nocov:
          end

          context 'when the item does not exist in the collection' do
            let(:expected_error) do
              Cuprum::Collections::Errors::NotFound.new(
                attribute_name:  collection.primary_key_name,
                attribute_value: attributes.fetch(
                  primary_key_name.to_s,
                  attributes[primary_key_name.intern]
                ),
                collection_name: collection.name,
                primary_key:     true
              )
            end
            let(:matching_data) { mapped_data.first }

            it 'should return a failing result' do
              expect(command.call(entity:))
                .to be_a_failing_result
                .with_error(expected_error)
            end

            it 'should not append an item to the collection' do
              expect { command.call(entity:) }
                .not_to(change { collection.query.count })
            end
          end

          context 'when the item exists in the collection' do
            let(:data) { fixtures_data }
            let(:matching_data) do
              mapped_data.first.merge(super())
            end

            it 'should return a passing result' do
              expect(command.call(entity:))
                .to be_a_passing_result
                .with_value(be == expected_data)
            end

            it 'should not append an item to the collection' do
              expect { command.call(entity:) }
                .not_to(change { collection.query.count })
            end

            it 'should set the attributes' do
              command.call(entity:)

              expect(scoped.to_a.first).to be == expected_data
            end
          end
        end
      end
    end

    # Contract validating the behavior of a ValidateOne command implementation.
    module ShouldBeAValidateOneCommandContract
      extend RSpec::SleepingKingStudios::Contract

      # @!method apply(example_group, default_contract:)
      #   Adds the contract to the example group.
      #
      #   @param default_contract [Boolean] if true, the command defines a
      #     default contract.
      #   @param example_group [RSpec::Core::ExampleGroup] the example group to
      #     which the contract is applied.
      contract do |default_contract:|
        describe '#call' do
          let(:attributes) { defined?(super()) ? super() : {} }
          let(:contract)   { defined?(super()) ? super() : nil }

          def call_command
            command.call(contract:, entity:)
          end

          if defined_deferred_examples? 'should validate the entity'
            include_deferred 'should validate the entity'
          else
            # :nocov:
            pending \
              'the command should validate the entity parameter, but entity ' \
              'validation is not defined - implement a "should validate the ' \
              'entity" deferred example group to resolve this warning'
            # :nocov:
          end

          describe 'with an invalid contract value' do
            let(:contract) { Object.new.freeze }

            include_deferred 'should validate the parameter',
              :contract,
              'sleeping_king_studios.tools.assertions.instance_of',
              expected: Stannum::Constraints::Base
          end

          describe 'with contract: nil' do
            if default_contract
              context 'when the entity does not match the default contract' do
                let(:attributes) { invalid_default_attributes }
                let(:expected_error) do
                  Cuprum::Collections::Errors::FailedValidation.new(
                    entity_class: entity.class,
                    errors:       expected_errors
                  )
                end

                it 'should return a failing result' do
                  expect(command.call(entity:))
                    .to be_a_failing_result
                    .with_error(expected_error)
                end
              end

              context 'when the entity matches the default contract' do
                let(:attributes) { valid_default_attributes }

                it 'should return a passing result' do
                  expect(command.call(entity:))
                    .to be_a_passing_result
                    .with_value(entity)
                end
              end
            else
              let(:attributes) { valid_attributes }
              let(:expected_error) do
                Cuprum::Collections::Errors::MissingDefaultContract.new(
                  entity_class: entity.class
                )
              end

              it 'should return a failing result' do
                expect(command.call(entity:))
                  .to be_a_failing_result
                  .with_error(expected_error)
              end
            end
          end

          describe 'with contract: value' do
            context 'when the entity does not match the contract' do
              let(:attributes) { invalid_attributes }
              let(:errors)     { contract.errors_for(entity) }
              let(:expected_error) do
                Cuprum::Collections::Errors::FailedValidation.new(
                  entity_class: entity.class,
                  errors:
                )
              end

              it 'should return a failing result' do
                expect(command.call(contract:, entity:))
                  .to be_a_failing_result
                  .with_error(expected_error)
              end
            end

            context 'when the entity matches the contract' do
              let(:attributes) { valid_attributes }

              it 'should return a passing result' do
                expect(command.call(contract:, entity:))
                  .to be_a_passing_result
                  .with_value(entity)
              end
            end
          end
        end
      end
    end

    # Contract asserting that the command validates the attributes parameter.
    module ShouldValidateTheAttributesContract
      extend RSpec::SleepingKingStudios::Contract

      # @!method apply(example_group)
      #   Adds the contract to the example group.
      #
      #   @param example_group [RSpec::Core::ExampleGroup] the example group to
      #     which the contract is applied.
      contract do
        describe 'with an invalid attributes value' do
          let(:attributes) { Object.new.freeze }

          include_deferred 'should validate the parameter',
            :attributes,
            'sleeping_king_studios.tools.assertions.instance_of',
            expected: Hash
        end

        describe 'with an attributes value with invalid keys' do
          let(:attributes) do
            {
              nil      => 'NilClass',
              'string' => 'String',
              symbol:     'Symbol'
            }
          end

          include_deferred 'should validate the parameter',
            'attributes[nil] key',
            'sleeping_king_studios.tools.assertions.presence'
        end
      end
    end

    # Contract asserting that the command validates the primary key parameter.
    module ShouldValidateThePrimaryKeyContract
      extend RSpec::SleepingKingStudios::Contract

      # @!method apply(example_group)
      #   Adds the contract to the example group.
      #
      #   @param example_group [RSpec::Core::ExampleGroup] the example group to
      #     which the contract is applied.
      contract do
        describe 'with an invalid primary key value' do
          let(:primary_key) { Object.new.freeze }
          let(:expected_error) do
            Cuprum::Errors::InvalidParameters.new(
              command_class: command.class,
              failures:      [
                tools.assertions.error_message_for(
                  'sleeping_king_studios.tools.assertions.instance_of',
                  as:       'primary_key',
                  expected: collection.primary_key_type
                )
              ]
            )
          end

          it 'should return a failing result with InvalidParameters error' do
            expect(call_command)
              .to be_a_failing_result
              .with_error(expected_error)
          end
        end
      end
    end

    # Contract asserting that the command validates the primary keys parameter.
    module ShouldValidateThePrimaryKeysContract
      extend RSpec::SleepingKingStudios::Contract

      # @!method apply(example_group)
      #   Adds the contract to the example group.
      #
      #   @param example_group [RSpec::Core::ExampleGroup] the example group to
      #     which the contract is applied.
      contract do
        describe 'with an invalid primary keys value' do
          let(:primary_keys) { Object.new.freeze }

          include_deferred 'should validate the parameter',
            :primary_keys,
            'sleeping_king_studios.tools.assertions.instance_of',
            expected: Array
        end

        describe 'with an attributes value with invalid keys' do
          let(:valid_primary_key_value) do
            defined?(super()) ? super() : 0
          end
          let(:primary_keys) do
            [
              nil,
              Object.new.freeze,
              valid_primary_key_value
            ]
          end
          let(:expected_error) do
            Cuprum::Errors::InvalidParameters.new(
              command_class: command.class,
              failures:      [
                tools.assertions.error_message_for(
                  'sleeping_king_studios.tools.assertions.instance_of',
                  as:       'primary_keys[0]',
                  expected: collection.primary_key_type
                ),
                tools.assertions.error_message_for(
                  'sleeping_king_studios.tools.assertions.instance_of',
                  as:       'primary_keys[1]',
                  expected: collection.primary_key_type
                )
              ]
            )
          end

          it 'should return a failing result with InvalidParameters error' do
            expect(call_command)
              .to be_a_failing_result
              .with_error(expected_error)
          end
        end
      end
    end
  end
end
