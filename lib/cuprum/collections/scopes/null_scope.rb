# frozen_string_literal: true

require 'cuprum/collections/scopes'
require 'cuprum/collections/scopes/base'
require 'cuprum/collections/scopes/null'

module Cuprum::Collections::Scopes
  # Generic scope class for defining collection-independent null scopes.
  class NullScope < Cuprum::Collections::Scopes::Base
    include Cuprum::Collections::Scopes::Null
  end
end
