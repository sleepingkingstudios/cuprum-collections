# frozen_string_literal: true

require 'cuprum/collections/scopes'

module Cuprum::Collections::Scopes
  # Defines a fluent interface for composing scopes.
  module Composition
    # @override and(hash = nil, &block)
    #   Parses the hash or block and combines using a logical AND.
    #
    #   @see Cuprum::Collections::Scopes::Criteria::Parser#parse.
    #
    # @override and(scope)
    #   Combines with the current scope using a logical AND.
    def and(*args, &block)
      return and_conjunction_scope(args.first) if conjunction_scope?(args.first)

      scope = builder.build(*args, &block)

      # We control the current and generated scopes, so we can skip validation
      # and transformation.
      builder.build_conjunction_scope(scopes: [self, scope], safe: false)
    end
    alias where and

    # @override not(hash = nil, &block)
    #   Parses and inverts the hash or block and combines using a logical AND.
    #
    #   @see Cuprum::Collections::Scopes::Criteria::Parser#parse.
    #
    # @override not(scope)
    #   Inverts and combines with the current scope using a logical AND.
    def not(*args, &block)
      return not_conjunction_scope(args.first) if conjunction_scope?(args.first)

      scope    = builder.build(*args, &block)
      inverted = builder.build_negation_scope(scopes: [scope], safe: false)

      # We control the current and generated scopes, so we can skip validation
      # and transformation.
      builder.build_conjunction_scope(scopes: [self, inverted], safe: false)
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

      # We control the current and generated scopes, so we can skip validation
      # and transformation.
      builder.build_disjunction_scope(scopes: [self, scope], safe: false)
    end

    private

    def and_conjunction_scope(scope)
      scopes = scope.scopes.map do |inner|
        builder.transform_scope(scope: inner)
      end

      builder.build_conjunction_scope(scopes: [self, *scopes], safe: false)
    end

    def conjunction_scope?(value)
      scope?(value) && value.type == :conjunction
    end

    def criteria_scope?(value)
      scope?(value) && value.type == :criteria
    end

    def disjunction_scope?(value)
      scope?(value) && value.type == :disjunction
    end

    def negation_scope?(value)
      scope?(value) && value.type == :negation
    end

    def not_conjunction_scope(scope)
      scopes = scope.scopes.map do |inner|
        builder.transform_scope(scope: inner)
      end
      inverted = builder.build_negation_scope(scopes: scopes, safe: false)

      builder.build_conjunction_scope(scopes: [self, inverted], safe: false)
    end

    def scope?(value)
      value.is_a?(Cuprum::Collections::Scopes::Base)
    end
  end
end
