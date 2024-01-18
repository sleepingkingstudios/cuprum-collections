# frozen_string_literal: true

require 'cuprum/collections/scopes'
require 'cuprum/collections/scopes/base'
require 'cuprum/collections/scopes/disjunction'

module Cuprum::Collections::Scopes
  # Generic scope class for defining collection-independent logical OR scopes.
  class DisjunctionScope < Cuprum::Collections::Scopes::Base
    include Cuprum::Collections::Scopes::Disjunction
  end
end
