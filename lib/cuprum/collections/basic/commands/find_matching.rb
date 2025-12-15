# frozen_string_literal: true

require 'stannum/constraints/boolean'

require 'cuprum/collections/basic/command'
require 'cuprum/collections/basic/commands'
require 'cuprum/collections/basic/query'
require 'cuprum/collections/commands/abstract_find_matching'
require 'cuprum/collections/constraints/ordering'

module Cuprum::Collections::Basic::Commands
  # Command for querying filtered, ordered data from a basic collection.
  class FindMatching < Cuprum::Collections::Basic::Command
    include Cuprum::Collections::Commands::AbstractFindMatching
  end
end
