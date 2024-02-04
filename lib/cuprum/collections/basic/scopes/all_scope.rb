# frozen_string_literal: true

require 'cuprum/collections/basic/scopes'
require 'cuprum/collections/basic/scopes/base'
require 'cuprum/collections/scopes/all'

module Cuprum::Collections::Basic::Scopes
  # Scope for returning unfiltered data.
  class AllScope < Cuprum::Collections::Basic::Scopes::Base
    include Cuprum::Collections::Scopes::All

    # @return [Cuprum::Collections::Basic::Scopes::AllScope] a cached instance
    #   of the all scope.
    def self.instance
      @instance ||= new
    end

    # Filters the provided data.
    def call(data:)
      raise ArgumentError, 'data must be an Array' unless data.is_a?(Array)

      data
    end
  end
end
