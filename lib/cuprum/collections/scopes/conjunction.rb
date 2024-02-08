# frozen_string_literal: true

require 'cuprum/collections/scopes'
require 'cuprum/collections/scopes/container'

module Cuprum::Collections::Scopes
  # Functionality for implementing a logical AND scope.
  module Conjunction
    include Cuprum::Collections::Scopes::Container

    # (see Cuprum::Collections::Scopes::Composition#and)
    def and(*args, &block)
      return super if scope?(args.first)

      with_scopes([*scopes, builder.build(*args, &block)])
    end
    alias where and

    # @return [Cuprum::Collections::Disjunction] a logical OR scope with the
    #   constituent scopes inverted.
    def invert
      builder.build_disjunction_scope(scopes: scopes.map(&:invert))
    end

    # (see Cuprum::Collections::Scopes::Composition#not)
    def not(*args, &block)
      return super if scope?(args.first)

      scope    = builder.build(*args, &block)
      inverted = builder.build_negation_scope(scopes: [scope], safe: false)

      with_scopes([*scopes, inverted])
    end

    # (see Cuprum::Collections::Scopes::Base#type)
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
      with_scopes([*scopes, builder.transform_scope(scope: scope)])
    end

    def not_conjunction_scope(scope)
      scopes = scope.scopes.map do |inner|
        builder.transform_scope(scope: inner)
      end
      inverted = builder.build_negation_scope(scopes: scopes, safe: false)

      with_scopes([*self.scopes, inverted])
    end

    def not_generic_scope(scope)
      scope    = builder.transform_scope(scope: scope)
      inverted = builder.build_negation_scope(scopes: [scope], safe: false)

      with_scopes([*scopes, inverted])
    end

    def not_negation_scope(scope)
      scopes = scope.scopes.map do |inner|
        builder.transform_scope(scope: inner)
      end

      with_scopes([*self.scopes, *scopes])
    end
  end
end
