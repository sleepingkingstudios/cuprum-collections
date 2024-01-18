# frozen_string_literal: true

require 'cuprum/collections/scopes'
require 'cuprum/collections/scopes/base'
require 'cuprum/collections/scopes/negation'

module Cuprum::Collections::Scopes
  # Generic scope class for defining collection-independent logical NAND scopes.
  class NegationScope < Cuprum::Collections::Scopes::Base
    include Cuprum::Collections::Scopes::Negation
  end
end
