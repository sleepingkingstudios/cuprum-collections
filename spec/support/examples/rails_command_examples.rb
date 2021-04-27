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
  end
end
