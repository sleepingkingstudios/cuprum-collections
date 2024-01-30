# frozen_string_literal: true

require 'cuprum/collections/scopes'
require 'cuprum/collections/scopes/criteria'

module Cuprum::Collections::Scopes
  # Abstraction for generating scopes for a given collection.
  module Building # rubocop:disable Metrics/ModuleLength
    # Error raised when trying to call an abstract builder method.
    class AbstractBuilderError < StandardError; end

    # Error raised when trying to transform an unknown scope type.
    class UnknownScopeTypeError < StandardError; end

    # Class methods to extend when including the module.
    module ClassMethods
      # @return [Cuprum::Collections::Scopes::Builder] a singleton instance of
      #   the builder class.
      def instance
        @instance ||= new
      end
    end

    class << self
      private

      def included(other)
        super

        other.extend(ClassMethods)
      end
    end

    # @override build(hash = nil, &block)
    #   Parses the hash or block and returns a criteria scope.
    #
    #   @see Cuprum::Collections::Scopes::Criteria::Parser#parse.
    #
    # @override build(scope)
    #   Returns a new scope with the same scope type and properties.
    def build(*args, &block)
      if args.first.is_a?(Cuprum::Collections::Scopes::Base)
        return transform_scope(scope: args.first)
      end

      criteria_scope_class.build(*args, &block)
    end

    # Creates a new all scope.
    def build_all_scope
      all_scope_class.new
    end

    # Creates a new logical AND scope wrapping the given scopes.
    #
    # @param scopes [Array<Cuprum::Collections::Scopes::Base>] the scopes to
    #   wrap in an AND scope.
    # @param safe [Boolean] if true, validates and converts the scopes to match
    #   the builder's scope classes. Defaults to true.
    def build_conjunction_scope(scopes:, safe: true)
      if safe
        validate_scopes!(scopes)

        scopes = transform_scopes(scopes)
      end

      conjunction_scope_class.new(scopes: scopes)
    end

    # Creates a new scope wrapping the given criteria.
    #
    # @param criteria [Array] the criteria for the scope.
    # @param safe [Boolean] if true, validates the criteria. Defaults to true.
    def build_criteria_scope(criteria:, safe: true)
      validate_criteria!(criteria) if safe

      criteria_scope_class.new(criteria: criteria)
    end

    # Creates a new logical OR scope wrapping the given scopes.
    #
    # @param scopes [Array<Cuprum::Collections::Scopes::Base>] the scopes to
    #   wrap in an AND scope.
    # @param safe [Boolean] if true, validates and converts the scopes to match
    #   the builder's scope classes. Defaults to true.
    def build_disjunction_scope(scopes:, safe: true)
      if safe
        validate_scopes!(scopes)

        scopes = transform_scopes(scopes)
      end

      disjunction_scope_class.new(scopes: scopes)
    end

    # Creates a new logical NAND scope wrapping the given scopes.
    #
    # @param scopes [Array<Cuprum::Collections::Scopes::Base>] the scopes to
    #   wrap in an AND scope.
    # @param safe [Boolean] if true, validates and converts the scopes to match
    #   the builder's scope classes. Defaults to true.
    def build_negation_scope(scopes:, safe: true)
      if safe
        validate_scopes!(scopes)

        scopes = transform_scopes(scopes)
      end

      negation_scope_class.new(scopes: scopes)
    end

    # Creates a new none scope.
    def build_none_scope
      none_scope_class.new
    end

    # Creates a new scope with the same scope type and properties.
    def transform_scope(scope:)
      validate_scope!(scope)

      build_transformed_scope(scope)
    end

    private

    def all_scope_class
      raise AbstractBuilderError,
        "#{self.class.name} is an abstract class. Define a builder " \
        'class and implement the #all_scope_class method.',
        caller(1..-1)
    end

    def build_transformed_scope(original) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
      case original.type
      when :all
        return original if original.is_a?(all_scope_class)

        build_all_scope
      when :conjunction
        return original if original.is_a?(conjunction_scope_class)

        build_conjunction_scope(
          safe:   false,
          scopes: transform_scopes(original.scopes)
        )
      when :criteria
        return original if original.is_a?(criteria_scope_class)

        build_criteria_scope(
          criteria: original.criteria,
          safe:     false
        )
      when :disjunction
        return original if original.is_a?(disjunction_scope_class)

        build_disjunction_scope(
          safe:   false,
          scopes: transform_scopes(original.scopes)
        )
      when :negation
        return original if original.is_a?(negation_scope_class)

        build_negation_scope(
          safe:   false,
          scopes: transform_scopes(original.scopes)
        )
      when :none
        return original if original.is_a?(none_scope_class)

        build_none_scope
      else
        error_message =
          "#{self.class.name} cannot transform scopes of type " \
          "#{original.type.inspect} (#{original.class.name})"

        raise UnknownScopeTypeError, error_message
      end
    end

    def conjunction_scope_class
      raise AbstractBuilderError,
        "#{self.class.name} is an abstract class. Define a builder " \
        'class and implement the #conjunction_scope_class method.',
        caller(1..-1)
    end

    def criteria_scope_class
      raise AbstractBuilderError,
        "#{self.class.name} is an abstract class. Define a builder " \
        'class and implement the #criteria_scope_class method.',
        caller(1..-1)
    end

    def disjunction_scope_class
      raise AbstractBuilderError,
        "#{self.class.name} is an abstract class. Define a builder " \
        'class and implement the #disjunction_scope_class method.',
        caller(1..-1)
    end

    def negation_scope_class
      raise AbstractBuilderError,
        "#{self.class.name} is an abstract class. Define a builder " \
        'class and implement the #negation_scope_class method.',
        caller(1..-1)
    end

    def none_scope_class
      raise AbstractBuilderError,
        "#{self.class.name} is an abstract class. Define a builder " \
        'class and implement the #none_scope_class method.',
        caller(1..-1)
    end

    def transform_scopes(scopes)
      scopes.map { |scope| build_transformed_scope(scope) }
    end

    def validate_criteria!(criteria)
      unless criteria.is_a?(Array)
        raise ArgumentError, 'criteria must be an Array', caller(1..-1)
      end

      return if criteria.all? do |criterion|
        criterion.is_a?(Array) && criterion.size == 3
      end

      raise ArgumentError, 'criterion must be an Array of size 3', caller(1..-1)
    end

    def validate_scope!(scope)
      return if scope.is_a?(Cuprum::Collections::Scopes::Base)

      raise ArgumentError, 'scope must be a Scope instance', caller(1..-1)
    end

    def validate_scopes!(scopes)
      unless scopes.is_a?(Array)
        raise ArgumentError, 'scopes must be an Array', caller(1..-1)
      end

      return if scopes.all? do |scope|
        scope.is_a?(Cuprum::Collections::Scopes::Base)
      end

      raise ArgumentError, 'scope must be a Scope instance', caller(1..-1)
    end
  end
end
