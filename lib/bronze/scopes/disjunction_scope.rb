# frozen_string_literal: true

require 'bronze/scopes/base'
require 'bronze/scopes'
require 'bronze/scopes/disjunction'

module Bronze::Scopes
  # Generic scope class for defining collection-independent logical OR scopes.
  class DisjunctionScope < Bronze::Scopes::Base
    include Bronze::Scopes::Disjunction
  end
end
