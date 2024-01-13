# frozen_string_literal: true

require 'cuprum/collections/basic/scopes'
require 'cuprum/collections/basic/scopes/base'
require 'cuprum/collections/scopes/container'

module Cuprum::Collections::Basic::Scopes
  # Scope for filtering data matching all of the given scopes.
  class ConjunctionScope < Cuprum::Collections::Basic::Scopes::Base
    include Cuprum::Collections::Scopes::Container

    # Returns true if the provided item matches all of the configured scopes.
    def match?(item:)
      super

      scopes.all? { |scope| scope.match?(item: item) }
    end
    alias matches? match?

    # (see Cuprum::Collections::Scopes::Base#type)
    def type
      :conjunction
    end
  end
end