# frozen_string_literal: true

require 'cuprum/collections/errors/already_exists'

require 'support/examples/find_error_examples'

RSpec.describe Cuprum::Collections::Errors::AlreadyExists do
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

  describe '::TYPE' do
    include_examples 'should define immutable constant',
      :TYPE,
      'cuprum.collections.errors.already_exists'
  end

  include_examples 'should implement the FindError methods', 'already exists'

  describe '#type' do
    include_examples 'should define reader', :type, described_class::TYPE
  end
end
