# frozen_string_literal: true

require 'bronze/scopes/conjunction'
require 'bronze/basic/scopes'
require 'bronze/basic/scopes/base'

module Bronze::Basic::Scopes
  # Scope for filtering data matching all of the given scopes.
  class ConjunctionScope < Bronze::Basic::Scopes::Base
    include Bronze::Scopes::Conjunction

    # Returns true if the provided item matches all of the configured scopes.
    def match?(item:)
      super

      scopes.all? { |scope| scope.match?(item:) }
    end
    alias matches? match?
  end
end
