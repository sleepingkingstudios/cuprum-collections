# frozen_string_literal: true

require 'bronze/scopes/all'
require 'cuprum/collections/basic/scopes'
require 'cuprum/collections/basic/scopes/base'

module Cuprum::Collections::Basic::Scopes
  # Scope for returning unfiltered data.
  class AllScope < Cuprum::Collections::Basic::Scopes::Base
    include Bronze::Scopes::All

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
