# frozen_string_literal: true

require 'cuprum/collections/basic'

module Cuprum::Collections::Basic
  # Namespace for commands implementing basic collection functionality.
  module Commands
    autoload :AssignOne,    'cuprum/collections/basic/commands/assign_one'
    autoload :BuildOne,     'cuprum/collections/basic/commands/build_one'
    autoload :FindMany,     'cuprum/collections/basic/commands/find_many'
    autoload :FindMatching, 'cuprum/collections/basic/commands/find_matching'
    autoload :FindOne,      'cuprum/collections/basic/commands/find_one'
    autoload :InsertOne,    'cuprum/collections/basic/commands/insert_one'
    autoload :UpdateOne,    'cuprum/collections/basic/commands/update_one'
    autoload :ValidateOne,  'cuprum/collections/basic/commands/validate_one'
  end
end
