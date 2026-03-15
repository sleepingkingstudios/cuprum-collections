# frozen_string_literal: true

require 'bronze/scopes'
require 'bronze/scopes/base'
require 'bronze/scopes/criteria'

module Bronze::Scopes
  # Generic scope class for defining criteria scopes.
  class CriteriaScope < Bronze::Scopes::Base
    include Bronze::Scopes::Criteria
  end
end
