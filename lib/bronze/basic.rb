# frozen_string_literal: true

require 'bronze'

module Bronze
  # The Basic collection is an example, in-memory collection implementation.
  module Basic
    # @overload new(**options)
    #   Returns a new instance of Basic::Collection.
    #
    #   @param options [Hash] Constructor options for the collection.
    #
    #   @see Bronze::Basic::Collection#initialize.
    #
    #   @deprecated [0.6.0] Use Bronze::Basic::Collection.new instead.
    def self.new(**)
      SleepingKingStudios::Tools::Toolbelt
        .instance
        .core_tools
        .deprecate(
          'Bronze::Basic.new',
          'Use Bronze::Basic::Collection.new instead.'
        )

      Bronze::Basic::Collection.new(**)
    end

    autoload :Collection, 'bronze/basic/collection'
    autoload :Command,    'bronze/basic/command'
    autoload :Commands,   'bronze/basic/commands'
    autoload :Query,      'bronze/basic/query'
    autoload :Repository, 'bronze/basic/repository'
    autoload :Scopes,     'bronze/basic/scopes'
  end
end
