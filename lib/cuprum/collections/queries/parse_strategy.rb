# frozen_string_literal: true

require 'cuprum/collections/queries'
require 'cuprum/collections/queries/parse_block'
require 'cuprum/collections/queries/parse_empty'
require 'cuprum/collections/errors/invalid_query'

module Cuprum::Collections::Queries
  # Command to select the parsing strategy for parsing Query#where parameters.
  class ParseStrategy < Cuprum::Command
    STRATEGIES = {
      empty: Cuprum::Collections::Queries::ParseEmpty,
      block: Cuprum::Collections::Queries::ParseBlock
    }.freeze
    private_constant :STRATEGIES

    # The :type of the error generated for an unknown parsing strategy.
    UNKNOWN_STRATEGY_ERROR =
      'cuprum.collections.errors.queries.unknown_strategy'

    private

    def find_and_validate_strategy(arguments:, block:, keywords:, strategy:)
      command_class = step { find_strategy_by_key(strategy: strategy) }
      match, errors = command_class::CONTRACT.match(
        arguments: arguments,
        block:     block,
        keywords:  keywords
      )

      return command_class if match

      failure(invalid_parameters_error(errors: errors, strategy: strategy))
    end

    def find_strategy(strategy:, **parameters)
      if strategy
        return find_and_validate_strategy(strategy: strategy, **parameters)
      end

      command_class = find_strategy_by_parameters(**parameters)

      return command_class if command_class

      failure(unknown_strategy_error(strategy: strategy))
    end

    def find_strategy_by_key(strategy:)
      STRATEGIES.fetch(strategy) do
        failure(unknown_strategy_error(strategy: strategy))
      end
    end

    def find_strategy_by_parameters(arguments:, block:, keywords:)
      STRATEGIES
        .values
        .find do |command_class|
          command_class::CONTRACT.matches?(
            arguments: arguments,
            block:     block,
            keywords:  keywords
          )
        end
    end

    def invalid_parameters_error(errors:, strategy:)
      Cuprum::Collections::Errors::InvalidQuery.new(
        errors:   errors,
        strategy: strategy
      )
    end

    def process(arguments: [], block: nil, keywords: {}, strategy: nil)
      command_class = step do
        find_strategy(
          arguments: arguments,
          block:     block,
          keywords:  keywords,
          strategy:  strategy
        )
      end

      command_class.new
    end

    def unknown_strategy_error(strategy:)
      errors = Stannum::Errors.new
      errors[:strategy].add(UNKNOWN_STRATEGY_ERROR, strategy: strategy)

      Cuprum::Collections::Errors::InvalidQuery.new(
        errors:   errors,
        strategy: strategy
      )
    end
  end
end
