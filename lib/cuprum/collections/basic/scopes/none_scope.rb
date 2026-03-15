# frozen_string_literal: true

require 'bronze/scopes/none'
require 'cuprum/collections/basic/scopes'
require 'cuprum/collections/basic/scopes/base'

module Cuprum::Collections::Basic::Scopes
  # Scope for returning an empty data set.
  class NoneScope < Cuprum::Collections::Basic::Scopes::Base
    include Bronze::Scopes::None

    # @return [Cuprum::Collections::Basic::Scopes::NoneScope] a cached instance
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
