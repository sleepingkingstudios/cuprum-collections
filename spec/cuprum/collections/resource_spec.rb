# frozen_string_literal: true

require 'cuprum/collections/resource'
require 'cuprum/collections/rspec/contracts/relation_contracts'

require 'support/book'
require 'support/grimoire'
require 'support/scoped_book'

RSpec.describe Cuprum::Collections::Resource do
  include Cuprum::Collections::RSpec::Contracts::RelationContracts

  subject(:resource) { described_class.new(**constructor_options) }

  let(:name)                { 'books' }
  let(:constructor_options) { { name: name } }

  include_contract 'should be a relation',
    cardinality: true

  include_contract 'should disambiguate parameter',
    :entity_class,
    as:    :resource_class,
    value: Grimoire

  include_contract 'should disambiguate parameter',
    :name,
    as: :resource_name

  include_contract 'should disambiguate parameter',
    :singular_name,
    as: :singular_resource_name

  include_contract 'should define primary keys'

  include_contract 'should define cardinality'
end
