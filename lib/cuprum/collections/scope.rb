# frozen_string_literal: true

require 'cuprum/collections'
require 'cuprum/collections/scopes/criteria_scope'

module Cuprum::Collections
  # Generic scope class for defining collection-independent criteria scopes.
  class Scope < Cuprum::Collections::Scopes::CriteriaScope
    # @overload build(value = nil, &block)
    #   (see Cuprum::Collections::Scopes::Criteria::ClassMethods.build)
    def self.build(...)
      new(...)
    end

    # @overload initialize(value = nil, &block)
    #   @param value [Hash, nil] the keys and values to parse.
    #
    #   @return [Array] the generated criteria.
    #
    #   @yield the query block.
    #
    #   @yieldreturn [Hash] a Hash with String keys.
    def initialize(*args, inverted: false, &block)
      criteria = self.class.parse(*args, &block)

      super(criteria: criteria, inverted: inverted)
    end
  end
end
