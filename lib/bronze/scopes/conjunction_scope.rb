# frozen_string_literal: true

require 'bronze/scopes'
require 'bronze/scopes/base'
require 'bronze/scopes/conjunction'

module Bronze::Scopes
  # Generic scope class for defining collection-independent logical AND scopes.
  class ConjunctionScope < Bronze::Scopes::Base
    include Bronze::Scopes::Conjunction
  end
end
