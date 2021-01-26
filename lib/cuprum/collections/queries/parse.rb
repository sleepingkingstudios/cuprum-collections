# frozen_string_literal: true

require 'cuprum/collections/queries'
require 'cuprum/collections/queries/parse_strategy'

module Cuprum::Collections::Queries
  # Command to parse parameters passed to Query#where into criteria.
  class Parse < Cuprum::Command
    private

    def process(where:, strategy: nil)
      command = step do
        Cuprum::Collections::Queries::ParseStrategy.new.call(
          strategy: strategy,
          where:    where
        )
      end

      command.call(where: where)
    end
  end
end
