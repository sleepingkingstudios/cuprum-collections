# frozen_string_literal: true

require 'cuprum/collections/basic/scopes'
require 'cuprum/collections/basic/scopes/base'
require 'cuprum/collections/scopes/null'

module Cuprum::Collections::Basic::Scopes
  # Scope for returning unfiltered data.
  class NullScope < Cuprum::Collections::Basic::Scopes::Base
    include Cuprum::Collections::Scopes::Null

    # Filters the provided data.
    def call(data:)
      raise ArgumentError, 'data must be an Array' unless data.is_a?(Array)

      data
    end
  end
end
