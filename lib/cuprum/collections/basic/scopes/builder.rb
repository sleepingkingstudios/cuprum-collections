# frozen_string_literal: true

require 'bronze/scopes/building'
require 'cuprum/collections/basic/scopes'

module Cuprum::Collections::Basic::Scopes
  # Builder for generating Basic collection scopes.
  class Builder
    include Bronze::Scopes::Building

    private

    def all_scope_class
      Cuprum::Collections::Basic::Scopes::AllScope
    end

    def conjunction_scope_class
      Cuprum::Collections::Basic::Scopes::ConjunctionScope
    end

    def criteria_scope_class
      Cuprum::Collections::Basic::Scopes::CriteriaScope
    end

    def disjunction_scope_class
      Cuprum::Collections::Basic::Scopes::DisjunctionScope
    end

    def none_scope_class
      Cuprum::Collections::Basic::Scopes::NoneScope
    end
  end
end

require 'cuprum/collections/basic/scopes/all_scope'
require 'cuprum/collections/basic/scopes/conjunction_scope'
require 'cuprum/collections/basic/scopes/criteria_scope'
require 'cuprum/collections/basic/scopes/disjunction_scope'
require 'cuprum/collections/basic/scopes/none_scope'
