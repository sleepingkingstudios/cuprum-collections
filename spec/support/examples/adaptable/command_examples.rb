# frozen_string_literal: true

require 'cuprum/collections'
require 'cuprum/collections/rspec/deferred/command_examples'
require 'cuprum/collections/rspec/fixtures'

require 'support/adaptable/query'
require 'support/examples/adaptable'

module Spec::Support::Examples::Adaptable
  module CommandExamples
    include RSpec::SleepingKingStudios::Deferred::Provider

    deferred_context 'with parameters for an adaptable collection' do
      let(:adapter) do
        Cuprum::Collections::Adapters::EntityAdapter
          .new(entity_class: Spec::BookEntity)
      end
      let(:collection) do
        Spec::AdaptableCollection.new(
          adapter:,
          data:,
          name:    'books',
          **collection_options
        )
      end
      let(:collection_options) { {} }
      let(:data)               { [] }
      let(:matching_data)      { data }
      let(:expected_data)      { convert_data_to_entities(matching_data) }
      let(:fixtures_data) do
        Cuprum::Collections::RSpec::Fixtures::BOOKS_FIXTURES.dup
      end

      define_method :convert_data_to_entities do |data|
        return Spec::BookEntity.new(**data) unless data.is_a?(Array)

        stringify_data(data).map do |maybe_attributes|
          next if maybe_attributes.nil?

          Spec::BookEntity.new(**maybe_attributes)
        end
      end

      define_method :stringify_data do |data|
        tools = SleepingKingStudios::Tools::HashTools.instance

        return tools.convert_keys_to_strings(data) unless data.is_a?(Array)

        data.map do |maybe_hash|
          next if maybe_hash.nil?

          tools.convert_keys_to_strings(maybe_hash)
        end
      end

      example_class 'Spec::AdaptableCollection',
        Cuprum::Collections::Basic::Collection \
      do |klass|
        klass.define_method :initialize do |adapter:, data: [], **options|
          super(data:, **options)

          @adapter = adapter
        end

        klass.attr_reader :adapter

        klass.define_method :query do
          Spec::Support::Adaptable::Query.new(data, adapter:)
        end
      end

      example_class 'Spec::BookEntity' do |klass|
        klass.include Stannum::Entity

        klass.define_primary_key :id,           Integer
        klass.define_attribute   :title,        String
        klass.define_attribute   :author,       String
        klass.define_attribute   :series,       String, optional: true
        klass.define_attribute   :category,     String, optional: true
        klass.define_attribute   :published_at, String, optional: true
      end
    end

    deferred_examples 'should validate the entity' do
      describe 'with an invalid entity value' do
        let(:entity) { Object.new.freeze }
        let(:expected_error) do
          error_message =
            SleepingKingStudios::Tools::Toolbelt
              .instance
              .assertions
              .error_message_for(
                'sleeping_king_studios.tools.assertions.instance_of',
                as:       'entity',
                expected: Spec::BookEntity
              )

          Cuprum::Errors::InvalidParameters.new(
            command_class: command.class,
            failures:      [error_message]
          )
        end

        it 'should return a failing result' do
          expect(call_command)
            .to be_a_failing_result
            .with_error(expected_error)
        end
      end
    end
  end
end
