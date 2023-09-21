# frozen_string_literal: true

require 'cuprum/collections/commands'

module Cuprum::Collections::Commands
  # Namespace for commands that operate on entity associations.
  module Associations
    autoload :FindMany, 'cuprum/collections/commands/associations'
  end
end
