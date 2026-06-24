# frozen_string_literal: true

require 'bronze/scopes/all'
require 'bronze/basic/scopes'
require 'bronze/basic/scopes/base'

module Bronze::Basic::Scopes
  # Scope for returning unfiltered data.
  class AllScope < Bronze::Basic::Scopes::Base
    include Bronze::Scopes::All

    # @return [Bronze::Basic::Scopes::AllScope] a cached instance
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
