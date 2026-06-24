# frozen_string_literal: true

require 'bronze/scopes/building'
require 'bronze/basic/scopes'

module Bronze::Basic::Scopes
  # Builder for generating Basic collection scopes.
  class Builder
    include Bronze::Scopes::Building

    private

    def all_scope_class
      Bronze::Basic::Scopes::AllScope
    end

    def conjunction_scope_class
      Bronze::Basic::Scopes::ConjunctionScope
    end

    def criteria_scope_class
      Bronze::Basic::Scopes::CriteriaScope
    end

    def disjunction_scope_class
      Bronze::Basic::Scopes::DisjunctionScope
    end

    def none_scope_class
      Bronze::Basic::Scopes::NoneScope
    end
  end
end

require 'bronze/basic/scopes/all_scope'
require 'bronze/basic/scopes/conjunction_scope'
require 'bronze/basic/scopes/criteria_scope'
require 'bronze/basic/scopes/disjunction_scope'
require 'bronze/basic/scopes/none_scope'
