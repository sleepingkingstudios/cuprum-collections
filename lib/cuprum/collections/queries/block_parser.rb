# frozen_string_literal: true

require 'cuprum/collections/queries'

module Cuprum::Collections::Queries
  # Internal class for parsing a Query#where block into criteria.
  class BlockParser
    # The operator for an equality operation.
    EQUALS = :eq

    # The operator for a not-equals operation.
    NOT_EQUAL = :ne

    # A set of all supported operators.
    OPERATORS = Set.new(
      [
        EQUALS,
        NOT_EQUAL
      ]
    ).freeze

    # Executes and parses the block into query criteria.
    #
    # The block is executed in the context of the query builder, which evaluates
    # operation methods such as #eq and #ne into partial criteria. Value
    # literals are converted to partial equality criteria. Finally, the
    # attribute names are merged with the partial criteria.
    #
    # Each criterion is represented as an Array with three elements:
    # - The name of the property or column to select by.
    # - The operation to filter, such as :eq (an equality operation).
    # - The expected value.
    #
    # @yield The block to be executed. Must return a Hash whose hash keys are
    #   the names of attributes or columns, and the corresponding values are
    #   either the literal value for that attribute or a method call for a valid
    #   operation.
    #
    # @return [Array<Array>] the parsed criteria.
    def call(&block)
      hsh = instance_exec(&block)

      validate_hash(hsh)
      generate_criteria(hsh)
    end

    # Generates an equality criterion.
    #
    # @return [Array] the equality criterion.
    def eq(value)
      [nil, EQUALS, value]
    end
    alias equals eq

    # Generates a negated equality criterion.
    #
    # @return [Array] the negated equality criterion.
    def ne(value)
      [nil, NOT_EQUAL, value]
    end
    alias not_equal ne

    private

    def generate_criteria(hsh)
      hsh.map do |key, value|
        next [key.to_s, EQUALS, value] unless partial_criterion?(value)

        value.tap { |ary| ary[0] = key.to_s }
      end
    end

    def partial_criterion?(obj)
      return false unless obj.is_a?(Array) && obj.size == 3

      attribute, operator, _value = obj

      return false unless attribute.nil?

      OPERATORS.include?(operator)
    end

    def valid_hash_key?(key)
      (key.is_a?(String) || key.is_a?(Symbol)) && !key.to_s.empty?
    end

    def validate_hash(hsh)
      unless hsh.is_a?(Hash)
        raise ArgumentError, 'block must return a Hash', caller(1..-1)
      end

      return if hsh.each_key.all? { |key| valid_hash_key?(key) }

      raise RuntimeError,
        'hash key must be a non-empty string or symbol',
        caller(1..-1)
    end
  end
end
