# frozen_string_literal: true

require 'stannum/constraints/boolean'

require 'cuprum/collections/basic/command'
require 'cuprum/collections/basic/commands'
require 'cuprum/collections/commands/abstract_find_many'

module Cuprum::Collections::Basic::Commands
  # Command for finding multiple collection items by primary key.
  class FindMany < Cuprum::Collections::Basic::Command
    include Cuprum::Collections::Commands::AbstractFindMany
  end
end
