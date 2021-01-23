# frozen_string_literal: true

require 'cuprum/collections/queries'
require 'cuprum/collections/queries/parse_strategy'

module Cuprum::Collections::Queries
  # Command to parse parameters passed to Query#where into criteria.
  class Parse < Cuprum::Command
    private

    def process(arguments: [], block: nil, keywords: {}, strategy: nil)
      return arguments.first if strategy == :unsafe

      command = step do
        Cuprum::Collections::Queries::ParseStrategy.new.call(
          arguments: arguments,
          block:     block,
          keywords:  keywords,
          strategy:  strategy
        )
      end

      command.call(arguments: arguments, block: block, keywords: keywords)
    end
  end
end
