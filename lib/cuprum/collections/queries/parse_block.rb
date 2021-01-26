# frozen_string_literal: true

require 'stannum/contracts/parameters_contract'

require 'cuprum/collections/command'
require 'cuprum/collections/constraints/query_hash'
require 'cuprum/collections/errors/invalid_query'
require 'cuprum/collections/errors/uncaught_exception'
require 'cuprum/collections/errors/unknown_operator'
require 'cuprum/collections/queries'

module Cuprum::Collections::Queries
  # Command for parsing a Query#where block into criteria.
  #
  # @example An Empty Query
  #   command = Cuprum::Collections::Queries::ParseBlock.new
  #   result  = command.call { {} }
  #   result.value #=> []
  #
  # @example A Value Query
  #   command = Cuprum::Collections::Queries::ParseBlock.new
  #   result  = command.call do
  #     {
  #       author: 'Nnedi Okorafor',
  #       series: 'Binti',
  #       genre:  'Africanfuturism'
  #     }
  #   end
  #   result.value #=>
  #   # [
  #   #   ['author', :eq, 'Nnedi Okorafor'],
  #   #   ['series', :eq, 'Binti'],
  #   #   ['genre',  :eq, 'Africanfuturism']
  #   # ]
  #
  # @example A Query With Operators
  #   command = Cuprum::Collections::Queries::ParseBlock.new
  #   result  = command.call do
  #     {
  #       author: equal('Nnedi Okorafor'),
  #       series: not_equal('Binti')
  #     }
  #   end
  #   result.value #=>
  #   # [
  #   #   ['author', :eq, 'Nnedi Okorafor'],
  #   #   ['series', :ne, 'Binti']
  #   # ]
  class ParseBlock < Cuprum::Collections::Command
    # Evaluation context for query blocks.
    class Builder < BasicObject
      # Generates an equality criterion.
      #
      # @return [Array] the equality criterion.
      def eq(value)
        [nil, Operators::EQUAL, value]
      end
      alias equals eq

      # Generates a negated equality criterion.
      #
      # @return [Array] the negated equality criterion.
      def ne(value)
        [nil, Operators::NOT_EQUAL, value]
      end
      alias not_equal ne
    end

    class << self
      public :parameters_contract
    end

    keyword :where, Proc

    private

    def call_block(&block)
      handle_unknown_operator { Builder.new.instance_exec(&block) }
    rescue StandardError => exception
      error = Cuprum::Collections::Errors::UncaughtException.new(
        exception: exception,
        message:   'uncaught exception when parsing query block'
      )

      failure(error)
    end

    def generate_criteria(hsh)
      hsh.map do |key, value|
        unless partial_criterion?(value)
          next [key.to_s, Cuprum::Collections::Queries::Operators::EQUAL, value]
        end

        value.tap { |ary| ary[0] = key.to_s }
      end
    end

    def handle_unknown_operator
      yield
    rescue NoMethodError => exception
      error = Cuprum::Collections::Errors::UnknownOperator.new(
        operator: exception.name
      )

      failure(error)
    end

    def invalid_query_error(errors:, message: nil)
      Cuprum::Collections::Errors::InvalidQuery.new(
        errors:   errors,
        message:  message,
        strategy: :block
      )
    end

    def partial_criterion?(obj)
      return false unless obj.is_a?(Array) && obj.size == 3

      attribute, operator, _value = obj

      return false unless attribute.nil?

      Cuprum::Collections::Queries::VALID_OPERATORS.include?(operator)
    end

    def process(where:)
      hsh = step { call_block(&where) }

      step { validate_hash(hsh) }

      generate_criteria(hsh)
    end

    def validate_hash(obj)
      constraint    = Cuprum::Collections::Constraints::QueryHash.new
      match, errors = constraint.match(obj)

      return if match

      message = 'query block returned invalid value'
      failure(invalid_query_error(errors: errors, message: message))
    end
  end
end
