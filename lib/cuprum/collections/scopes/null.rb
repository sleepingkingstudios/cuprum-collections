# frozen_string_literal: true

require 'cuprum/collections/scopes'

module Cuprum::Collections::Scopes
  # Functionality for implementing a null scope.
  module Null
    # @override and(hash = nil, &block)
    #   Parses the hash or block and returns the parsed scope.
    #
    #   @see Cuprum::Collections::Scopes::Criteria::Parser#parse.
    #
    # @override and(scope)
    #   Returns the given scope.
    def and(...)
      builder.build(...)
    end
    alias where and

    # @return [Boolean] true.
    def empty?
      true
    end

    # @override or(hash = nil, &block)
    #   Parses the hash or block and returns the parsed scope.
    #
    #   @see Cuprum::Collections::Scopes::Criteria::Parser#parse.
    #
    # @override or(scope)
    #   Returns the given scope.
    def or(...)
      builder.build(...)
    end

    # @override not(hash = nil, &block)
    #   Parses and inverts the hash or block and returns the inverted scope.
    #
    #   @see Cuprum::Collections::Scopes::Criteria::Parser#parse.
    #
    # @override not(scope)
    #   Inverts and returns the given scope.
    def not(...)
      scope = builder.build(...)

      builder.build_negation_scope(scopes: [scope], safe: false)
    end

    # (see Cuprum::Collections::Scopes::Base#type)
    def type
      :null
    end
  end
end
