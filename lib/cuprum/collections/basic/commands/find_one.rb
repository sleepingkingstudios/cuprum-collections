# frozen_string_literal: true

require 'stannum/constraints/boolean'

require 'bronze/commands/abstract_find_one'
require 'cuprum/collections/basic/command'
require 'cuprum/collections/basic/commands'

module Cuprum::Collections::Basic::Commands
  # Command for finding one collection item by primary key.
  class FindOne < Cuprum::Collections::Basic::Command
    include Bronze::Commands::AbstractFindOne
  end
end
