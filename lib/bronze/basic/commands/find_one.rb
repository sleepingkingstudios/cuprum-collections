# frozen_string_literal: true

require 'stannum/constraints/boolean'

require 'bronze/basic/command'
require 'bronze/basic/commands'
require 'bronze/commands/abstract_find_one'

module Bronze::Basic::Commands
  # Command for finding one collection item by primary key.
  class FindOne < Bronze::Basic::Command
    include Bronze::Commands::AbstractFindOne
  end
end
