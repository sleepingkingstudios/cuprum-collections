# frozen_string_literal: true

require 'stannum/constraints/boolean'

require 'cuprum/collections/basic/command'
require 'cuprum/collections/basic/commands'
require 'cuprum/collections/commands/abstract_find_one'

module Cuprum::Collections::Basic::Commands
  # Command for finding one collection item by primary key.
  class FindOne < Cuprum::Collections::Basic::Command
    include Cuprum::Collections::Commands::AbstractFindOne
  end
end
