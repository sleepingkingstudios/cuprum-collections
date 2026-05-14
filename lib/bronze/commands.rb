# frozen_string_literal: true

require 'bronze'

module Bronze
  # Namespace for abstract and collection-independent commands.
  module Commands
    autoload :AbstractFindMany,     'bronze/commands/abstract_find_many'
    autoload :AbstractFindMatching, 'bronze/commands/abstract_find_matching'
    autoload :AbstractFindOne,      'bronze/commands/abstract_find_one'
    autoload :Base,                 'bronze/commands/base'
    autoload :Associations,         'bronze/commands/associations'
    autoload :Create,               'bronze/commands/create'
    autoload :FindOneMatching,      'bronze/commands/find_one_matching'
    autoload :Update,               'bronze/commands/update'
    autoload :Upsert,               'bronze/commands/upsert'

    # @deprecated [0.6.0]
    autoload :QueryCommand, 'bronze/commands/query_command'
  end
end
