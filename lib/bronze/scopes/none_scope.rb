# frozen_string_literal: true

require 'bronze/scopes'
require 'bronze/scopes/base'
require 'bronze/scopes/none'

module Bronze::Scopes
  # Generic scope class for defining collection-independent none scopes.
  class NoneScope < Bronze::Scopes::Base
    include Bronze::Scopes::None

    # @return [Bronze::Scopes::NoneScope] a cached instance of the none scope.
    def self.instance
      @instance ||= new
    end
  end
end
