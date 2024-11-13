# frozen_string_literal: true

require 'cuprum/collections/resource'
require 'cuprum/collections/rspec/deferred/resource_examples'

require 'support/book'
require 'support/grimoire'
require 'support/scoped_book'

RSpec.describe Cuprum::Collections::Resource do
  include Cuprum::Collections::RSpec::Deferred::ResourceExamples

  subject(:resource) { described_class.new(**constructor_options) }

  let(:name)                { 'books' }
  let(:constructor_options) { { name: } }

  include_deferred 'should be a Resource'
end
