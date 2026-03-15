# frozen_string_literal: true

require 'bronze/scopes/disjunction'
require 'cuprum/collections/basic/scopes'
require 'cuprum/collections/basic/scopes/base'

module Cuprum::Collections::Basic::Scopes
  # Scope for filtering data matching any of the given scopes.
  class DisjunctionScope < Cuprum::Collections::Basic::Scopes::Base
    include Bronze::Scopes::Disjunction

    # Returns true if the provided item matches any of the configured scopes.
    def match?(item:)
      super

      scopes.any? { |scope| scope.match?(item:) }
    end
    alias matches? match?
  end
end
