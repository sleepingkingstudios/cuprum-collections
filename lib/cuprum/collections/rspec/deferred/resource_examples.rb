# frozen_string_literal: true

require 'rspec/sleeping_king_studios/deferred'

require 'cuprum/collections/rspec/deferred'
require 'cuprum/collections/rspec/deferred/relation_examples'

module Cuprum::Collections::RSpec::Deferred
  # Deferred examples for testing resources.
  module ResourceExamples
    include RSpec::SleepingKingStudios::Deferred::Provider

    deferred_examples 'should be a Resource' do
      include Cuprum::Collections::RSpec::Deferred::RelationExamples

      include_deferred 'should be a Relation',
        cardinality: true

      include_deferred 'should define Relation cardinality'

      include_deferred 'should define Relation primary key'
    end
  end
end
