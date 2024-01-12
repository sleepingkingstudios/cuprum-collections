# frozen_string_literal: true

require 'cuprum/collections/scopes'
require 'cuprum/collections/scopes/base'
require 'cuprum/collections/scopes/container'

module Cuprum::Collections::Scopes
  # Generic scope class for defining collection-independent logical AND scopes.
  class ConjunctionScope < Cuprum::Collections::Scopes::Base
    include Cuprum::Collections::Scopes::Container

    # (see Cuprum::Collections::Scopes::Base#type)
    def type
      :conjunction
    end
  end
end
