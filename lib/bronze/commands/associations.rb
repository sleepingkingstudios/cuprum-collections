# frozen_string_literal: true

require 'bronze/commands'

module Bronze::Commands
  # Namespace for commands that operate on entity associations.
  module Associations
    autoload :FindMany,    'bronze/commands/associations/find_many'
    autoload :RequireMany, 'bronze/commands/associations/require_many'
  end
end
