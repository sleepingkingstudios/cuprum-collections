# frozen_string_literal: true

require 'stannum/constraints/boolean'

require 'bronze/commands/abstract_find_many'
require 'cuprum/collections/basic/command'
require 'cuprum/collections/basic/commands'

module Cuprum::Collections::Basic::Commands
  # Command for finding multiple collection items by primary key.
  class FindMany < Cuprum::Collections::Basic::Command
    include Bronze::Commands::AbstractFindMany
  end
end
