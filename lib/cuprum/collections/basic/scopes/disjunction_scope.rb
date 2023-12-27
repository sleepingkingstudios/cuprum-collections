# frozen_string_literal: true

require 'cuprum/collections/basic/scope'
require 'cuprum/collections/basic/scopes'
require 'cuprum/collections/scopes/container'

module Cuprum::Collections::Basic::Scopes
  # Scope for filtering data matching any of the given scopes.
  class DisjunctionScope < Cuprum::Collections::Basic::Scope
    include Cuprum::Collections::Scopes::Container

    # Returns true if the provided item matches any of the configured scopes.
    def match?(item:)
      super

      scopes.any? { |scope| scope.match?(item: item) }
    end
    alias matches? match?
  end
end
