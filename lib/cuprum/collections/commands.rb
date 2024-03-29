# frozen_string_literal: true

require 'cuprum/collections'

module Cuprum::Collections
  # Namespace for abstract commands and collection-independent commands.
  module Commands
    autoload :Associations,    'cuprum/collections/commands/associations'
    autoload :Create,          'cuprum/collections/commands/create'
    autoload :FindOneMatching, 'cuprum/collections/commands/find_one_matching'
    autoload :QueryCommand,    'cuprum/collections/commands/query_command'
    autoload :Update,          'cuprum/collections/commands/update'
    autoload :Upsert,          'cuprum/collections/commands/upsert'
  end
end
