# frozen_string_literal: true

require 'cuprum/collections/scopes'

module Cuprum::Collections::Scopes
  # Functionality for implementing an all scope, which returns all data.
  module All
    # @override and(hash = nil, &block)
    #   Parses the hash or block and returns the parsed scope.
    #
    #   @see Cuprum::Collections::Scopes::Criteria::Parser#parse.
    #
    # @override and(scope)
    #   Returns the given scope.
    def and(*args, &block)
      return self if scope?(args.first) && args.first.empty?

      builder.build(*args, &block)
    end
    alias where and

    # @return [Boolean] false.
    def empty?
      false
    end

    # @override or(hash = nil, &block)
    #   Parses the hash or block and returns the parsed scope.
    #
    #   @see Cuprum::Collections::Scopes::Criteria::Parser#parse.
    #
    # @override or(scope)
    #   Returns the given scope.
    def or(*args, &block)
      return self if scope?(args.first) && args.first.empty?

      builder.build(*args, &block)
    end

    # @override not(hash = nil, &block)
    #   Parses and inverts the hash or block and returns the inverted scope.
    #
    #   @see Cuprum::Collections::Scopes::Criteria::Parser#parse.
    #
    # @override not(scope)
    #   Inverts and returns the given scope.
    def not(*args, &block)
      return super if scope?(args.first)

      scope = builder.build(*args, &block)

      builder.build_negation_scope(scopes: [scope], safe: false)
    end

    # (see Cuprum::Collections::Scopes::Base#type)
    def type
      :all
    end

    private

    def not_conjunction_scope(scope)
      scopes = scope.scopes.map do |inner|
        builder.transform_scope(scope: inner)
      end

      builder.build_negation_scope(scopes: scopes, safe: false)
    end

    def not_generic_scope(scope)
      scope = builder.transform_scope(scope: scope)

      builder.build_negation_scope(scopes: [scope], safe: false)
    end

    def not_negation_scope(scope)
      scopes = scope.scopes.map do |inner|
        builder.transform_scope(scope: inner)
      end

      return scopes.first if scopes.size == 1

      builder.build_conjunction_scope(scopes: scopes, safe: false)
    end
  end
end
