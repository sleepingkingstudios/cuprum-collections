# frozen_string_literal: true

require 'cuprum/collections/scopes'
require 'cuprum/collections/scopes/building'

module Cuprum::Collections::Scopes
  # Builder for generating generic scopes.
  class Builder
    include Cuprum::Collections::Scopes::Building

    private

    def conjunction_scope_class
      Cuprum::Collections::Scopes::ConjunctionScope
    end

    def criteria_scope_class
      Cuprum::Collections::Scopes::CriteriaScope
    end

    def disjunction_scope_class
      Cuprum::Collections::Scopes::DisjunctionScope
    end

    def negation_scope_class
      Cuprum::Collections::Scopes::NegationScope
    end

    def null_scope_class
      Cuprum::Collections::Scopes::NullScope
    end
  end
end

require 'cuprum/collections/scopes/conjunction_scope'
require 'cuprum/collections/scopes/criteria_scope'
require 'cuprum/collections/scopes/disjunction_scope'
require 'cuprum/collections/scopes/negation_scope'
require 'cuprum/collections/scopes/null_scope'
