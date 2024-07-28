# frozen_string_literal: true

require 'cuprum/collections/queries'
require 'cuprum/collections/scopes'

module Cuprum::Collections::Scopes
  # Functionality for implementing a criteria scope.
  module Criteria # rubocop:disable Metrics/ModuleLength
    # Class methods to extend when including the module.
    module ClassMethods
      # @overload build(value = nil, &block)
      #   Initializes a new criteria scope with the parsed criteria.
      #
      #   @param value [Hash, nil] the keys and values to parse.
      #
      #   @return [Criteria] the scope with the generated criteria.
      #
      #   @yield the query block.
      #
      #   @yieldreturn [Hash] a Hash with String keys.
      def build(...)
        criteria = parse(...)

        new(criteria: criteria)
      end

      # @overload parse(value = nil, &block)
      #   (see Cuprum::Collections::Scopes::Criteria::Parser#parse)
      def parse(*args, &block)
        parser = Cuprum::Collections::Scopes::Criteria::Parser.instance

        args.empty? ? parser.parse(&block) : parser.parse(args.first, &block)
      end
    end

    class << self
      private

      def included(other)
        super

        other.extend(ClassMethods)
      end
    end

    # @param criteria [Array] the criteria used for filtering query data.
    # @param inverted [Boolean] if true, the criteria are inverted and should
    #   match on any criterion (per DeMorgan's Laws).
    # @param options [Hash] additional options for the scope.
    def initialize(criteria:, inverted: false, **options)
      super(**options)

      @criteria = criteria
      @inverted = inverted
    end

    # @return [Array] the criteria used for filtering query data.
    attr_reader :criteria

    # @param other [Object] the object to compare.
    #
    # @return [Boolean] true if the other object is a scope with matching type
    #   and criteria; otherwise false.
    def ==(other)
      return false unless super

      other.criteria == criteria && other.inverted? == inverted?
    end

    # (see Cuprum::Collections::Scopes::Composition#and)
    def and(*args, &block)
      return super if scope?(args.first)

      return self.class.build(*args, &block) if empty?

      return super if inverted?

      with_criteria([*criteria, *self.class.parse(*args, &block)])
    end
    alias where and

    # (see Cuprum::Collections::Scopes::Base#as_json)
    def as_json
      super.merge({ 'criteria' => criteria, 'inverted' => inverted? })
    end

    # @private
    def debug
      # :nocov:
      message = "#{super} (#{criteria.count})"
      message += ' (inverted)' if inverted?

      return message if empty?

      criteria.reduce("#{message}:") do |str, (attribute, operator, value)|
        str + "\n- #{attribute.inspect} #{operator} #{value.inspect}"
      end
      # :nocov:
    end

    # @return [Boolean] true if the scope has no criteria; otherwise false.
    def empty?
      @criteria.empty?
    end

    # @return [Cuprum::Collections::Criteria] a copy of the scope with the
    #   #inverted? predicate flipped and the individual criteria negated.
    def invert
      with_criteria(invert_criteria).tap { |copy| copy.inverted = !inverted? }
    end

    # @return [Boolean] true if the scope is inverted; otherwise false.
    def inverted?
      @inverted
    end

    # (see Cuprum::Collections::Scopes::Composition#or)
    def or(*args, &block)
      return super if scope?(args.first)

      return self.class.build(*args, &block) if empty?

      builder.build_disjunction_scope(
        safe:   false,
        scopes: [self, self.class.build(*args, &block)]
      )
    end

    # (see Cuprum::Collections::Scopes::Base#type)
    def type
      :criteria
    end

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

    attr_writer :inverted

    private

    def and_all_scope(scope)
      return builder.transform_scope(scope: scope) if empty?

      super
    end

    def and_conjunction_scope(scope)
      return builder.transform_scope(scope: scope) if empty?

      super
    end

    def and_criteria_scope(scope)
      return builder.transform_scope(scope: scope) if empty?

      unless inverted? || scope.inverted?
        return with_criteria([*criteria, *scope.criteria])
      end

      super
    end

    def and_generic_scope(scope)
      return builder.transform_scope(scope: scope) if empty?

      super
    end

    def invert_criteria
      criteria.map do |(attribute, operator, value)|
        [attribute, invert_operator(operator), value]
      end
    end

    def invert_operator(operator)
      Cuprum::Collections::Queries::INVERTIBLE_OPERATORS.fetch(operator) do
        raise Cuprum::Collections::Queries::UninvertibleOperatorException,
          "uninvertible operator #{operator.inspect}"
      end
    end

    def or_disjunction_scope(scope)
      return builder.transform_scope(scope: scope) if empty?

      super
    end

    def or_generic_scope(scope)
      return builder.transform_scope(scope: scope) if empty?

      super
    end
  end
end

require 'cuprum/collections/scopes/criteria/parser'
