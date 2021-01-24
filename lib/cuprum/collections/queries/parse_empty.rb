# frozen_string_literal: true

require 'stannum/contracts/parameters_contract'

require 'cuprum/collections/queries'

module Cuprum::Collections::Queries
  # Command for generating empty criteria from empty Query#where parameters.
  class ParseEmpty < Cuprum::Command
    # Contract for validating the Query parameters.
    CONTRACT = Stannum::Contracts::ParametersContract.new do
      block false
    end.freeze

    private

    def process(arguments: [], block: nil, keywords: {}) # rubocop:disable Lint/UnusedMethodArgument
      []
    end
  end
end
