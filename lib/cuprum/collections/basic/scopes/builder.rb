# frozen_string_literal: true

require 'cuprum/collections/basic/scopes'
require 'cuprum/collections/scopes/building'

module Cuprum::Collections::Basic::Scopes
  # Builder for generating Basic collection scopes.
  class Builder
    include Cuprum::Collections::Scopes::Building

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

    def negation_scope_class
      Cuprum::Collections::Basic::Scopes::NegationScope
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
require 'cuprum/collections/basic/scopes/negation_scope'
require 'cuprum/collections/basic/scopes/none_scope'
