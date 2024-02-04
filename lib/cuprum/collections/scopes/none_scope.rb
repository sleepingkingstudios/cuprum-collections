# frozen_string_literal: true

require 'cuprum/collections/scopes'
require 'cuprum/collections/scopes/base'
require 'cuprum/collections/scopes/none'

module Cuprum::Collections::Scopes
  # Generic scope class for defining collection-independent none scopes.
  class NoneScope < Cuprum::Collections::Scopes::Base
    include Cuprum::Collections::Scopes::None

    # @return [Cuprum::Collections::Scopes::NoneScope] a cached instance of the
    #   none scope.
    def self.instance
      @instance ||= new
    end
  end
end
