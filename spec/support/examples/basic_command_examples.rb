# frozen_string_literal: true

require 'rspec/sleeping_king_studios/concerns/shared_example_group'

require 'cuprum/collections/rspec/fixtures'

require 'support/examples'

module Spec::Support::Examples
  module BasicCommandExamples
    extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

    shared_context 'with parameters for a basic contract' do
      let(:collection_name)     { 'books' }
      let(:data)                { [] }
      let(:mapped_data)         { data }
      let(:constructor_options) { {} }
      let(:expected_options)    { {} }
      let(:primary_key_name)    { :id }
      let(:primary_key_type)    { Integer }
      let(:entity_type) do
        Stannum::Constraints::Types::HashWithStringKeys.new
      end
      let(:fixtures_data) do
        Cuprum::Collections::RSpec::BOOKS_FIXTURES.dup
      end
    end

    shared_context 'with a custom primary key' do
      let(:primary_key_name) { :uuid }
      let(:primary_key_type) { String }
      let(:constructor_options) do
        super().merge(
          primary_key_name: primary_key_name,
          primary_key_type: primary_key_type
        )
      end
      let(:mapped_data) do
        data.map do |item|
          item.dup.tap do |hsh|
            value = hsh.delete('id').to_s.rjust(12, '0')

            hsh['uuid'] = "00000000-0000-0000-0000-#{value}"
          end
        end
      end
      let(:invalid_primary_key_value) { '00000000-0000-0000-0000-000000000100' }
      let(:valid_primary_key_value)   { '00000000-0000-0000-0000-000000000000' }
      let(:invalid_primary_key_values) do
        %w[
          00000000-0000-0000-0000-000000000100
          00000000-0000-0000-0000-000000000101
          00000000-0000-0000-0000-000000000102
        ]
      end
      let(:valid_primary_key_values) do
        %w[
          00000000-0000-0000-0000-000000000000
          00000000-0000-0000-0000-000000000001
          00000000-0000-0000-0000-000000000002
        ]
      end
    end
  end
end
