# frozen_string_literal: true

require 'cuprum/collections/scopes'

module Cuprum::Collections::Scopes
  # Functionality for implementing a criteria scope.
  module Criteria
    # @param criteria [Array] the criteria used for filtering query data.
    def initialize(criteria:, **options)
      super(**options)

      @criteria = criteria
    end

    # @return [Array] the criteria used for filtering query data.
    attr_reader :criteria

    # Creates a copy of the scope with the given criteria.
    #
    # @param criteria [Array] the criteria used for filtering query data.
    #
    # @return [Scope] the copied scope.
    def with_criteria(criteria)
      dup.tap { |copy| copy.criteria = criteria }
    end

    protected

    attr_writer :criteria
  end
end
