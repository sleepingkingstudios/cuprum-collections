# frozen_string_literal: true

require 'cuprum/collections/scopes'

module Cuprum::Collections::Scopes
  # Defines a fluent interface for composing scopes.
  module Composition
    autoload :Conjunction, 'cuprum/collections/scopes/composition/conjunction'

    # @override and(hash = nil, &block)
    #   Parses the hash or block and combines using a logical AND.
    #
    #   @see Cuprum::Collections::Scopes::Criteria::Parser#parse.
    #
    # @override and(scope)
    #   Combines with the current scope using a logical AND.
    def and(...)
      scope = builder.build(...)

      builder.build_conjunction_scope(scopes: [self, scope])
    end
    alias where and

    # @override not(hash = nil, &block)
    #   Parses and inverts the hash or block and combines using a logical AND.
    #
    #   @see Cuprum::Collections::Scopes::Criteria::Parser#parse.
    #
    # @override not(scope)
    #   Inverts and combines with the current scope using a logical AND.
    def not(...)
      scope    = builder.build(...)
      inverted = builder.build_negation_scope(scopes: [scope])

      builder.build_conjunction_scope(scopes: [self, inverted])
    end

    # @override and(hash = nil, &block)
    #   Parses the hash or block and combines using a logical OR.
    #
    #   @see Cuprum::Collections::Scopes::Criteria::Parser#parse.
    #
    # @override and(scope)
    #   Combines with the current scope using a logical OR.
    def or(...)
      scope = builder.build(...)

      builder.build_disjunction_scope(scopes: [self, scope])
    end
  end
end
