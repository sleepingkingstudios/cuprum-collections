# frozen_string_literal: true

require 'cuprum/collections/scopes'
require 'cuprum/collections/scopes/building'

module Cuprum::Collections::Scopes
  # Builder for generating generic scopes.
  class Builder
    include Cuprum::Collections::Scopes::Building

    private

    def all_scope_class
      Cuprum::Collections::Scopes::AllScope
    end

    def conjunction_scope_class
      Cuprum::Collections::Scopes::ConjunctionScope
    end

    def criteria_scope_class
      Cuprum::Collections::Scopes::CriteriaScope
    end

    def disjunction_scope_class
      Cuprum::Collections::Scopes::DisjunctionScope
    end

    def none_scope_class
      Cuprum::Collections::Scopes::NoneScope
    end
  end
end

require 'cuprum/collections/scopes/all_scope'
require 'cuprum/collections/scopes/conjunction_scope'
require 'cuprum/collections/scopes/criteria_scope'
require 'cuprum/collections/scopes/disjunction_scope'
require 'cuprum/collections/scopes/none_scope'
