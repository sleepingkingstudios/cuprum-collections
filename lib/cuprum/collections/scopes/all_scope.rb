# frozen_string_literal: true

require 'cuprum/collections/scopes'
require 'cuprum/collections/scopes/all'
require 'cuprum/collections/scopes/base'

module Cuprum::Collections::Scopes
  # Generic scope class for defining collection-independent all scopes.
  class AllScope < Cuprum::Collections::Scopes::Base
    include Cuprum::Collections::Scopes::All

    # @return [Cuprum::Collections::Scopes::AllScope] a cached instance of the
    #   all scope.
    def self.instance
      @instance ||= new
    end
  end
end
