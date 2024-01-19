# frozen_string_literal: true

require 'cuprum/collections/scopes'

module Cuprum::Collections::Scopes
  # Functionality for implementing a scope container.
  module Container
    # @param scopes [Array<Scope>] the scopes wrapped by the scope.
    # @param options [Hash] additional options for the scope.
    def initialize(scopes:, **options)
      super(**options)

      @scopes = scopes
    end

    # @return [Array<Scope>] the scopes wrapped by the scope.
    attr_reader :scopes

    # @param other [Object] the object to compare.
    #
    # @return [Boolean] true if the other object is a scope with matching type
    #   and child scopes; otherwise false.
    def ==(other)
      return false unless super

      other.scopes == scopes
    end

    # @return [Boolean] true if the scope has no child scopes; otherwise false.
    def empty?
      @scopes.empty?
    end

    # Creates a copy of the scope with the given child scopes.
    #
    # @param scopes [Array] the child scopes.
    #
    # @return [Scope] the copied scope.
    def with_scopes(scopes)
      dup.tap { |copy| copy.scopes = scopes }
    end

    protected

    attr_writer :scopes
  end
end
