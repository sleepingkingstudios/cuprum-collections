# frozen_string_literal: true

require 'bronze/scopes'
require 'bronze/scopes/building'

module Bronze::Scopes
  # Builder for generating generic scopes.
  class Builder
    include Bronze::Scopes::Building

    private

    def all_scope_class
      Bronze::Scopes::AllScope
    end

    def conjunction_scope_class
      Bronze::Scopes::ConjunctionScope
    end

    def criteria_scope_class
      Bronze::Scopes::CriteriaScope
    end

    def disjunction_scope_class
      Bronze::Scopes::DisjunctionScope
    end

    def none_scope_class
      Bronze::Scopes::NoneScope
    end
  end
end
