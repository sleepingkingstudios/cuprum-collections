# frozen_string_literal: true

require 'bronze/scopes/none'
require 'bronze/basic/scopes'
require 'bronze/basic/scopes/base'

module Bronze::Basic::Scopes
  # Scope for returning an empty data set.
  class NoneScope < Bronze::Basic::Scopes::Base
    include Bronze::Scopes::None

    # @return [Bronze::Basic::Scopes::NoneScope] a cached instance
    #   of the none scope.
    def self.instance
      @instance ||= new
    end

    # Filters the provided data.
    def call(data:)
      raise ArgumentError, 'data must be an Array' unless data.is_a?(Array)

      []
    end

    # Returns false for all items.
    def match?(item:)
      super

      false
    end
    alias matches? match?
  end
end
