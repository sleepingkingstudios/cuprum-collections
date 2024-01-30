# frozen_string_literal: true

require 'cuprum/collections/scopes'

module Cuprum::Collections::Scopes
  # Defines a fluent interface for composing scopes.
  module Composition # rubocop:disable Metrics/ModuleLength
    # @override and(hash = nil, &block)
    #   Parses the hash or block and combines using a logical AND.
    #
    #   @see Cuprum::Collections::Scopes::Criteria::Parser#parse.
    #
    # @override and(scope)
    #   Combines with the current scope using a logical AND.
    #
    #   Returns self if the given scope is empty.
    def and(*args, &block)
      if scope?(args.first)
        return and_scope(args.first) || and_generic_scope(args.first)
      end

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
    #
    #   Returns self if the given scope is empty.
    def not(*args, &block)
      if scope?(args.first)
        return not_scope(args.first) || not_generic_scope(args.first)
      end

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
    #
    #   Returns self if the given scope is empty.
    def or(*args, &block)
      if scope?(args.first)
        return or_scope(args.first) || or_generic_scope(args.first)
      end

      scope = builder.build(*args, &block)

      # We control the current and generated scopes, so we can skip validation
      # and transformation.
      builder.build_disjunction_scope(scopes: [self, scope], safe: false)
    end

    private

    def and_all_scope(_)
      self
    end

    def and_criteria_scope(scope)
      and_generic_scope(scope)
    end

    def and_conjunction_scope(scope)
      scopes = scope.scopes.map do |inner|
        builder.transform_scope(scope: inner)
      end

      builder.build_conjunction_scope(scopes: [self, *scopes], safe: false)
    end

    def and_disjunction_scope(scope)
      and_generic_scope(scope)
    end

    def and_generic_scope(scope)
      scope = builder.transform_scope(scope: scope)

      # We control the current and generated scopes, so we can skip validation
      # and transformation.
      builder.build_conjunction_scope(scopes: [self, scope], safe: false)
    end

    def and_negation_scope(scope)
      and_generic_scope(scope)
    end

    def and_scope(scope) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/MethodLength
      return self if scope.empty?

      case scope.type
      when :all
        and_all_scope(scope)
      when :conjunction
        and_conjunction_scope(scope)
      when :criteria
        and_criteria_scope(scope)
      when :disjunction
        and_disjunction_scope(scope)
      when :negation
        and_negation_scope(scope)
      when :none
        scope
      end
    end

    def not_all_scope(_)
      builder.build_none_scope
    end

    def not_conjunction_scope(scope)
      scopes = scope.scopes.map do |inner|
        builder.transform_scope(scope: inner)
      end
      inverted = builder.build_negation_scope(scopes: scopes, safe: false)

      builder.build_conjunction_scope(scopes: [self, inverted], safe: false)
    end

    def not_criteria_scope(scope)
      not_generic_scope(scope)
    end

    def not_disjunction_scope(scope)
      not_generic_scope(scope)
    end

    def not_generic_scope(scope)
      scope    = builder.transform_scope(scope: scope)
      inverted = builder.build_negation_scope(scopes: [scope], safe: false)

      # We control the current and generated scopes, so we can skip validation
      # and transformation.
      builder.build_conjunction_scope(scopes: [self, inverted], safe: false)
    end

    def not_negation_scope(scope)
      scopes = scope.scopes.map do |inner|
        builder.transform_scope(scope: inner)
      end

      builder.build_conjunction_scope(scopes: [self, *scopes], safe: false)
    end

    def not_scope(scope) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/MethodLength
      return self if scope.empty?

      case scope.type
      when :all
        not_all_scope(scope)
      when :conjunction
        not_conjunction_scope(scope)
      when :criteria
        not_criteria_scope(scope)
      when :disjunction
        not_disjunction_scope(scope)
      when :negation
        not_negation_scope(scope)
      when :none
        self
      end
    end

    def or_all_scope(scope)
      builder.transform_scope(scope: scope)
    end

    def or_conjunction_scope(scope)
      or_generic_scope(scope)
    end

    def or_criteria_scope(scope)
      or_generic_scope(scope)
    end

    def or_disjunction_scope(scope)
      scopes = scope.scopes.map do |inner|
        builder.transform_scope(scope: inner)
      end

      builder.build_disjunction_scope(scopes: [self, *scopes], safe: false)
    end

    def or_generic_scope(scope)
      scope = builder.transform_scope(scope: scope)

      # We control the current and generated scopes, so we can skip validation
      # and transformation.
      builder.build_disjunction_scope(scopes: [self, scope], safe: false)
    end

    def or_negation_scope(scope)
      or_generic_scope(scope)
    end

    def or_scope(scope) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/MethodLength
      return self if scope.empty?

      case scope.type
      when :all
        or_all_scope(scope)
      when :conjunction
        or_conjunction_scope(scope)
      when :criteria
        or_criteria_scope(scope)
      when :disjunction
        or_disjunction_scope(scope)
      when :negation
        or_negation_scope(scope)
      when :none
        self
      end
    end

    def scope?(value)
      value.is_a?(Cuprum::Collections::Scopes::Base)
    end
  end
end
