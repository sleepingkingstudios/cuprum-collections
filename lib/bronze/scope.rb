# frozen_string_literal: true

require 'bronze'
require 'bronze/scopes/criteria_scope'

module Bronze
  # Generic scope class for defining collection-independent criteria scopes.
  class Scope < Bronze::Scopes::CriteriaScope
    # @overload build(value = nil, &block)
    #   (see Bronze::Scopes::Criteria::ClassMethods.build)
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
    def initialize(*, inverted: false, &)
      criteria = self.class.parse(*, &)

      super(criteria:, inverted:)
    end
  end
end
