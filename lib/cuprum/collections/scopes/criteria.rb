# frozen_string_literal: true

require 'cuprum/collections/queries'
require 'cuprum/collections/scopes'

module Cuprum::Collections::Scopes
  # Functionality for implementing a criteria scope.
  module Criteria
    # Class methods to extend when including the module.
    module ClassMethods
      # @override build(value = nil, &block)
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

      # @override parse(value = nil, &block)
      #   (see Cuprum::Collections::Scopes::Criteria::Parser#parse)
      def parse(*args, &block)
        parser = Cuprum::Collections::Scopes::Criteria::Parser.instance

        args.empty? ? parser.parse(&block) : parser.parse(args.first, &block)
      end
    end

    # Helper for generating criteria from hash or block inputs.
    class Parser # rubocop:disable Metrics/ClassLength
      OperatorExpression = Struct.new(:operator, :value)
      private_constant :OperatorExpression

      UNKNOWN = Object.new.freeze
      private_constant :UNKNOWN

      class << self
        # @return [Cuprum::Collections::Scopes::Criteria::Parser] a singleton
        #   instance of the parser class.
        def instance
          @instance ||= new
        end

        # @private
        def validate_hash(value)
          return if valid_hash?(value)

          message = 'value must be a Hash with String or Symbol keys'

          raise ArgumentError, message, caller(1..-1)
        end

        private

        def valid_hash?(value)
          return false unless value.is_a?(Hash)

          value.each_key.all? do |key|
            key.is_a?(String) || key.is_a?(Symbol)
          end
        end
      end

      # @override parse(value = nil, &block)
      #   Converts a valid query hash and/or block to criteria.
      #
      #   The block must return a Hash with String keys. The hash values must
      #   either be literal values (e.g. a String, an Integer, etc) or a call to
      #   an operator function.
      #
      #   @param value [Hash, nil] the keys and values to parse.
      #
      #   @return [Array] the generated criteria.
      #
      #   @yield the query block.
      #
      #   @yieldreturn [Hash] a Hash with String keys.
      def parse(value = UNKNOWN, &block)
        if block_given? && value != UNKNOWN
          parse_hash(value) + parse_block(&block)
        elsif value == UNKNOWN
          parse_block(&block)
        else
          parse_hash(value)
        end
      end

      # Converts a valid query block to criteria.
      #
      # The block must return a Hash with String keys. The hash values must
      # either be literal values (e.g. a String, an Integer, etc) or a call to
      # an operator function.
      #
      # @return [Array] the generated criteria.
      #
      # @yield the query block.
      #
      # @yieldreturn [Hash] a Hash with String keys.
      def parse_block(...) # rubocop:disable Metrics/MethodLength
        raise ArgumentError, 'no block given' unless block_given?

        value = instance_exec(...)

        Parser.validate_hash(value)

        value.map do |attribute, filter|
          if filter.is_a?(OperatorExpression)
            [attribute.to_s, filter.operator, filter.value]
          else
            operator = Cuprum::Collections::Queries::Operators::EQUAL

            [attribute.to_s, operator, filter]
          end
        end
      rescue NameError => exception
        raise Cuprum::Collections::Queries::UnknownOperatorException,
          %(unknown operator "#{exception.name}")
      end

      # Converts a hash of expected keys and values to criteria.
      #
      # @param value [Hash] the keys and values to parse.
      #
      # @return [Array] the generated criteria.
      def parse_hash(value)
        Parser.validate_hash(value)

        operator = Cuprum::Collections::Queries::Operators::EQUAL

        value.map do |attribute, filter|
          [attribute.to_s, operator, filter]
        end
      end

      private

      def equals(value)
        OperatorExpression.new(
          Cuprum::Collections::Queries::Operators::EQUAL,
          value
        )
      end
      alias equal equals
      alias eq equals

      def greater_than(value)
        OperatorExpression.new(
          Cuprum::Collections::Queries::Operators::GREATER_THAN,
          value
        )
      end
      alias gt greater_than

      def greater_than_or_equal_to(value)
        OperatorExpression.new(
          Cuprum::Collections::Queries::Operators::GREATER_THAN_OR_EQUAL_TO,
          value
        )
      end
      alias gte greater_than_or_equal_to

      def less_than(value)
        OperatorExpression.new(
          Cuprum::Collections::Queries::Operators::LESS_THAN,
          value
        )
      end
      alias lt less_than

      def less_than_or_equal_to(value)
        OperatorExpression.new(
          Cuprum::Collections::Queries::Operators::LESS_THAN_OR_EQUAL_TO,
          value
        )
      end
      alias lte less_than_or_equal_to

      def not_equal(value)
        OperatorExpression.new(
          Cuprum::Collections::Queries::Operators::NOT_EQUAL,
          value
        )
      end
      alias ne not_equal

      def not_one_of(*values)
        OperatorExpression.new(
          Cuprum::Collections::Queries::Operators::NOT_ONE_OF,
          values.flatten
        )
      end

      def one_of(*values)
        OperatorExpression.new(
          Cuprum::Collections::Queries::Operators::ONE_OF,
          values.flatten
        )
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

      with_criteria([*criteria, *self.class.parse(*args, &block)])
    end
    alias where and

    # (see Cuprum::Colletions::Scopes::Base#as_json)
    def as_json
      super().merge({ 'criteria' => criteria, 'inverted' => inverted? })
    end

    # @private
    def debug
      # :nocov:
      message = "#{super} (#{criteria.count})"

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
      with_criteria([*criteria, *scope.criteria])
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
