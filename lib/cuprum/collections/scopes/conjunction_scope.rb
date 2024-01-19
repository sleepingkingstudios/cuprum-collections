# frozen_string_literal: true

require 'cuprum/collections/scopes'
require 'cuprum/collections/scopes/base'
require 'cuprum/collections/scopes/conjunction'

module Cuprum::Collections::Scopes
  # Generic scope class for defining collection-independent logical AND scopes.
  class ConjunctionScope < Cuprum::Collections::Scopes::Base
    include Cuprum::Collections::Scopes::Conjunction
  end
end
