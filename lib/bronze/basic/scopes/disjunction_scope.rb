# frozen_string_literal: true

require 'bronze/scopes/disjunction'
require 'bronze/basic/scopes'
require 'bronze/basic/scopes/base'

module Bronze::Basic::Scopes
  # Scope for filtering data matching any of the given scopes.
  class DisjunctionScope < Bronze::Basic::Scopes::Base
    include Bronze::Scopes::Disjunction

    # Returns true if the provided item matches any of the configured scopes.
    def match?(item:)
      super

      scopes.any? { |scope| scope.match?(item:) }
    end
    alias matches? match?
  end
end
