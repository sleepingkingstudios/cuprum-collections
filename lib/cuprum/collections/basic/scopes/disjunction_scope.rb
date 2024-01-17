# frozen_string_literal: true

require 'cuprum/collections/basic/scopes'
require 'cuprum/collections/basic/scopes/base'
require 'cuprum/collections/scopes/composition/disjunction'
require 'cuprum/collections/scopes/container'

module Cuprum::Collections::Basic::Scopes
  # Scope for filtering data matching any of the given scopes.
  class DisjunctionScope < Cuprum::Collections::Basic::Scopes::Base
    include Cuprum::Collections::Scopes::Container
    include Cuprum::Collections::Scopes::Composition::Disjunction

    # Returns true if the provided item matches any of the configured scopes.
    def match?(item:)
      super

      scopes.any? { |scope| scope.match?(item: item) }
    end
    alias matches? match?

    # (see Cuprum::Collections::Scopes::Base#type)
    def type
      :disjunction
    end
  end
end
