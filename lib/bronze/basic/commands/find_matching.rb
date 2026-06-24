# frozen_string_literal: true

require 'stannum/constraints/boolean'

require 'bronze/basic/command'
require 'bronze/basic/commands'
require 'bronze/basic/query'
require 'bronze/commands/abstract_find_matching'

module Bronze::Basic::Commands
  # Command for querying filtered, ordered data from a basic collection.
  class FindMatching < Bronze::Basic::Command
    include Bronze::Commands::AbstractFindMatching
  end
end
