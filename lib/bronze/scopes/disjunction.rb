# frozen_string_literal: true

require 'bronze/scopes'
require 'bronze/scopes/container'

module Bronze::Scopes
  # Functionality for implementing a logical OR scope.
  module Disjunction
    include Bronze::Scopes::Container

    # @return [Cuprum::Collections::Disjunction] a logical AND scope with the
    #   constituent scopes inverted.
    def invert
      builder.build_conjunction_scope(scopes: scopes.map(&:invert))
    end

    # (see Bronze::Scopes::Composition#or)
    def or(*args, &)
      return super if scope?(args.first)

      scope = builder.build(*args, &)

      with_scopes([*scopes, scope])
    end

    # (see Bronze::Scopes::Base#type)
    def type
      :disjunction
    end

    private

    def or_disjunction_scope(scope)
      scopes = scope.scopes.map do |inner|
        builder.transform_scope(scope: inner)
      end

      with_scopes([*self.scopes, *scopes])
    end

    def or_generic_scope(scope)
      with_scopes([*scopes, builder.transform_scope(scope:)])
    end
  end
end
