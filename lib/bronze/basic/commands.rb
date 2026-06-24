# frozen_string_literal: true

require 'bronze/basic'

module Bronze::Basic
  # Namespace for commands implementing basic collection functionality.
  module Commands
    autoload :AssignOne,    'bronze/basic/commands/assign_one'
    autoload :BuildOne,     'bronze/basic/commands/build_one'
    autoload :DestroyOne,   'bronze/basic/commands/destroy_one'
    autoload :FindMany,     'bronze/basic/commands/find_many'
    autoload :FindMatching, 'bronze/basic/commands/find_matching'
    autoload :FindOne,      'bronze/basic/commands/find_one'
    autoload :InsertOne,    'bronze/basic/commands/insert_one'
    autoload :UpdateOne,    'bronze/basic/commands/update_one'
    autoload :ValidateOne,  'bronze/basic/commands/validate_one'
  end
end
