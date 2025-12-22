# frozen_string_literal: true

require 'cuprum/collections/errors/not_unique'

require 'support/examples/find_error_examples'

RSpec.describe Cuprum::Collections::Errors::NotUnique do
  include Spec::Support::Examples::FindErrorExamples

  subject(:error) { described_class.new(**constructor_options) }

  let(:attribute_name)     { 'title' }
  let(:attribute_value)    { 'Gideon the Ninth' }
  let(:name)               { 'books' }
  let(:collection_options) { { name: } }
  let(:constructor_options) do
    {
      attribute_name:,
      attribute_value:,
      **collection_options
    }
  end

  describe '::TYPE' do
    include_examples 'should define immutable constant',
      :TYPE,
      'cuprum.collections.errors.not_unique'
  end

  include_examples 'should implement the FindError methods', 'not unique'

  describe '#type' do
    include_examples 'should define reader', :type, described_class::TYPE
  end
end
