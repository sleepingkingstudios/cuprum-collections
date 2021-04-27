# frozen_string_literal: true

require 'rspec/sleeping_king_studios/concerns/shared_example_group'

require 'cuprum/collections/rspec/fixtures'

require 'support/book'
require 'support/examples'
require 'support/tome'

module Spec::Support::Examples
  module RailsCommandExamples
    extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

    shared_context 'with parameters for a Rails command' do
      let(:data)                { [] }
      let(:record_class)        { Book }
      let(:collection_name)     { 'books' }
      let(:constructor_options) { {} }
      let(:expected_options)    { {} }
      let(:primary_key_name)    { :id }
      let(:primary_key_type)    { Integer }
      let(:entity_type)         { record_class }
      let(:fixtures_data) do
        Cuprum::Collections::RSpec::BOOKS_FIXTURES.dup
      end

      before(:example) do
        data.each { |attributes| Book.create!(attributes) }
      end
    end

    shared_examples 'should validate the :entity keyword' do
      describe 'with an invalid entity' do
        let(:entity) { Tome.new }
        let(:expected_error) do
          type     = record_class
          contract = Stannum::Contracts::ParametersContract.new do
            keyword :entity, type
          end
          errors = contract.errors_for(
            {
              arguments: [],
              keywords:  { entity: entity },
              block:     nil
            }
          )

          Cuprum::Collections::Errors::InvalidParameters.new(
            command: command,
            errors:  errors
          )
        end

        it 'should validate the :entity keyword' do
          expect(command.call(attributes: {}, entity: entity))
            .to be_a_failing_result
            .with_error(expected_error)
        end
      end
    end
  end
end
