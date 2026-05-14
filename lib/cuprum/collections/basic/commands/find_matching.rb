# frozen_string_literal: true

require 'stannum/constraints/boolean'

require 'bronze/commands/abstract_find_matching'
require 'cuprum/collections/basic/command'
require 'cuprum/collections/basic/commands'
require 'cuprum/collections/basic/query'

module Cuprum::Collections::Basic::Commands
  # Command for querying filtered, ordered data from a basic collection.
  class FindMatching < Cuprum::Collections::Basic::Command
    include Bronze::Commands::AbstractFindMatching
  end
end
