# frozen_string_literal: true

require 'cuprum/collections'

module Cuprum::Collections
  # The Basic collection is an example, in-memory collection implementation.
  module Basic
    # Returns a new instance of Basic::Collection.
    #
    # @param options [Hash] Constructor options for the collection.
    #
    # @see Cuprum::Collections::Basic::Collection#initialize.
    def self.new(**options)
      Cuprum::Collections::Basic::Collection.new(**options)
    end

    autoload :Collection, 'cuprum/collections/basic/collection'
    autoload :Command,    'cuprum/collections/basic/command'
    autoload :Commands,   'cuprum/collections/basic/commands'
    autoload :Query,      'cuprum/collections/basic/query'
    autoload :Repository, 'cuprum/collections/basic/repository'
    autoload :Scope,      'cuprum/collections/basic/scope'
    autoload :Scopes,     'cuprum/collections/basic/scopes'
  end
end
