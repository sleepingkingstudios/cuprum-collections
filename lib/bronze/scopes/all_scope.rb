# frozen_string_literal: true

require 'bronze/scopes'
require 'bronze/scopes/all'
require 'bronze/scopes/base'

module Bronze::Scopes
  # Generic scope class for defining collection-independent all scopes.
  class AllScope < Bronze::Scopes::Base
    include Bronze::Scopes::All

    # @return [Bronze::Scopes::AllScope] a cached instance of the all scope.
    def self.instance
      @instance ||= new
    end
  end
end
