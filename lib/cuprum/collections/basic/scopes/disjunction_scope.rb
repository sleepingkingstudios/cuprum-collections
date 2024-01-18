# frozen_string_literal: true

require 'cuprum/collections/basic/scopes'
require 'cuprum/collections/basic/scopes/base'
require 'cuprum/collections/scopes/disjunction'

module Cuprum::Collections::Basic::Scopes
  # Scope for filtering data matching any of the given scopes.
  class DisjunctionScope < Cuprum::Collections::Basic::Scopes::Base
    include Cuprum::Collections::Scopes::Disjunction

    # Returns true if the provided item matches any of the configured scopes.
    def match?(item:)
      super

      scopes.any? { |scope| scope.match?(item: item) }
    end
    alias matches? match?
  end
end
