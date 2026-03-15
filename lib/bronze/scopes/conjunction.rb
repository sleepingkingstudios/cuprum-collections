# frozen_string_literal: true

require 'bronze/scopes'
require 'bronze/scopes/container'

module Bronze::Scopes
  # Functionality for implementing a logical AND scope.
  module Conjunction
    include Bronze::Scopes::Container

    # (see Bronze::Scopes::Composition#and)
    def and(*args, &)
      return super if scope?(args.first)

      with_scopes([*scopes, builder.build(*args, &)])
    end
    alias where and

    # @return [Cuprum::Collections::Disjunction] a logical OR scope with the
    #   constituent scopes inverted.
    def invert
      builder.build_disjunction_scope(scopes: scopes.map(&:invert))
    end

    # (see Bronze::Scopes::Base#type)
    def type
      :conjunction
    end

    private

    def and_conjunction_scope(scope)
      scopes = scope.scopes.map do |inner|
        builder.transform_scope(scope: inner)
      end

      with_scopes([*self.scopes, *scopes])
    end

    def and_generic_scope(scope)
      with_scopes([*scopes, builder.transform_scope(scope:)])
    end
  end
end
