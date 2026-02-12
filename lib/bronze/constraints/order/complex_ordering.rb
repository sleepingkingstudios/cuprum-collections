# frozen_string_literal: true

require 'bronze/constraints/order'
require 'bronze/constraints/order/attributes_array'
require 'bronze/constraints/order/attributes_hash'

module Bronze::Constraints::Order
  # Asserts that the object is an attributes Array with an sort order Hash.
  class ComplexOrdering < Stannum::Constraints::Base
    # @return [Bronze::Constraints::Order::AttributesArray] a cached instance of
    #   the constraint with default options.
    def self.instance
      @instance ||= new
    end

    # Checks that the given object is a complex ordering.
    #
    # A complex ordering is a data structure consisting of an Array of zero or
    # more attribute names, with the last item in the array a Hash of attribute
    # names and sort directions, e.g. [:title, :author, { publisher: 'asc' }].
    #
    # @param actual [Object] The object to match.
    #
    # @return [true, false] true if the object matches the expected properties
    #   or behavior, otherwise false.
    def matches?(actual)
      return false unless actual.is_a?(Array)

      array = actual.dup
      hash  = array.pop

      array_constraint.matches?(array) && hash_constraint.matches?(hash)
    end
    alias match? matches?

    private

    def array_constraint
      Bronze::Constraints::Order::AttributesArray.instance
    end

    def hash_constraint
      Bronze::Constraints::Order::AttributesHash.instance
    end
  end
end
