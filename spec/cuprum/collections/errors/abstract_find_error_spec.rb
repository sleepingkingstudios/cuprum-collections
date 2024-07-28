# frozen_string_literal: true

require 'cuprum/collections/errors/abstract_find_error'

require 'support/examples/find_error_examples'

RSpec.describe Cuprum::Collections::Errors::AbstractFindError do
  include Spec::Support::Examples::FindErrorExamples

  subject(:error) { described_class.new(**constructor_options) }

  let(:attribute_name)  { 'title' }
  let(:attribute_value) { 'Gideon the Ninth' }
  let(:collection_name) { 'books' }
  let(:constructor_options) do
    {
      attribute_name:,
      attribute_value:,
      collection_name:
    }
  end

  include_examples 'should implement the FindError methods', 'query failed'
end
