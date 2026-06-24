# frozen_string_literal: true

require 'stannum/constraints/boolean'

require 'bronze/basic/command'
require 'bronze/basic/commands'
require 'bronze/commands/abstract_find_many'

module Bronze::Basic::Commands
  # Command for finding multiple collection items by primary key.
  class FindMany < Bronze::Basic::Command
    include Bronze::Commands::AbstractFindMany
  end
end
