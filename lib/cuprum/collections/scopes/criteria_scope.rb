# frozen_string_literal: true

require 'cuprum/collections/scopes'
require 'cuprum/collections/scopes/base'
require 'cuprum/collections/scopes/composition/criteria'
require 'cuprum/collections/scopes/criteria'

module Cuprum::Collections::Scopes
  class CriteriaScope < Cuprum::Collections::Scopes::Base
    include Cuprum::Collections::Scopes::Criteria
    include Cuprum::Collections::Scopes::Composition::Criteria
  end
end
