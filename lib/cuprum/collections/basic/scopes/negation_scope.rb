# frozen_string_literal: true

require 'cuprum/collections/basic/scopes'
require 'cuprum/collections/basic/scopes/base'
require 'cuprum/collections/scopes/container'

module Cuprum::Collections::Basic::Scopes
  # Scope for filtering data not matching at least one of the given scopes.
  class NegationScope < Cuprum::Collections::Basic::Scopes::Base
    include Cuprum::Collections::Scopes::Container

    # Returns true if the provided item does not match at least one scope.
    def match?(item:)
      super

      scopes.any? { |scope| !scope.match?(item: item) }
    end
    alias matches? match?
  end
end
