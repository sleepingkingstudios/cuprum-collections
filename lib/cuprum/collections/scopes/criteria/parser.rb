# frozen_string_literal: true

require 'forwardable'

require 'cuprum/collections/scopes/criteria'

module Cuprum::Collections::Scopes::Criteria
  # Helper for generating criteria from hash or block inputs.
  class Parser
    # Utility class for parsing block operators.
    class BlockParser
      # @return [BlockParser] a memoized class instance.
      def self.instance
        @instance ||= new
      end

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

    # @deprecated v0.5.0 Implicit receivers are deprecated. Remove this class
    #   when removing the functionality.
    class ImplicitReceiver
      ERROR_MESSAGE =
        'Pass a block with one parameter to #parse: { |scope| { ' \
        'scope.%s: value } }'
      private_constant :ERROR_MESSAGE

      OPERATORS = %i[
        eq
        equal
        equals
        greater_than
        greater_than_or_equal_to
        gt
        gte
        less_than
        less_than_or_equal_to
        lt
        lte
        ne
        not_equal
        not_one_of
        one_of
      ].freeze
      private_constant :OPERATORS

      OPERATORS.each do |operator|
        define_method(operator) do |*args, **kwargs, &block|
          tools.core_tools.deprecate(
            '#parse with implicit receiver',
            message: format(ERROR_MESSAGE, operator)
          )

          BlockParser.instance.send(operator, *args, **kwargs, &block)
        end
      end

      private

      def tools
        SleepingKingStudios::Tools::Toolbelt.instance
      end
    end

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

    # @overload parse(value = nil, &block)
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
    def parse(value = UNKNOWN, &)
      if block_given? && value != UNKNOWN
        parse_hash(value) + parse_block(&)
      elsif value == UNKNOWN
        parse_block(&)
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

      value = evaluate_block(...)

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

    # @deprecated v0.5.0 Implicit receivers are deprecated.
    def evaluate_block(&block)
      receiver = ImplicitReceiver.new

      return receiver.instance_exec(&block) if block.arity.zero?

      receiver.instance_exec(BlockParser.instance, &block)
    end
  end
end
