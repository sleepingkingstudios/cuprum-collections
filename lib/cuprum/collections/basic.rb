# frozen_string_literal: true

require 'cuprum/collections'

module Cuprum::Collections
  # The Basic collection is an example, in-memory collection implementation.
  module Basic
    # @overload new(**options)
    #   Returns a new instance of Basic::Collection.
    #
    #   @param options [Hash] Constructor options for the collection.
    #
    #   @see Cuprum::Collections::Basic::Collection#initialize.
    def self.new(**)
      Cuprum::Collections::Basic::Collection.new(**)
    end

    autoload :Collection, 'cuprum/collections/basic/collection'
    autoload :Command,    'cuprum/collections/basic/command'
    autoload :Commands,   'cuprum/collections/basic/commands'
    autoload :Query,      'cuprum/collections/basic/query'
    autoload :Repository, 'cuprum/collections/basic/repository'
    autoload :Scopes,     'cuprum/collections/basic/scopes'
  end
end
