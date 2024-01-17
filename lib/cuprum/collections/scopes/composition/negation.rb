# frozen_string_literal: true

require 'cuprum/collections/scopes/composition'

module Cuprum::Collections::Scopes::Composition
  # Defines composition behavior for negation scopes.
  module Negation
    include Cuprum::Collections::Scopes::Composition

    # (see Cuprum::Collections::Scopes::Composition#and)
    def and(*args, &block)
      return super unless negation_scope?(args.first)

      scopes = args.first.scopes.map do |scope|
        builder.transform_scope(scope: scope)
      end

      with_scopes([*self.scopes, *scopes])
    end
    alias where and

    # (see Cuprum::Collections::Scopes::Composition#not)
    def not(*args, &block)
      return super unless negation_scope?(args.first)

      scopes = args.first.scopes.map do |scope|
        builder.transform_scope(scope: scope)
      end

      return scopes.first if scopes.size == 1

      builder.build_conjunction_scope(scopes: scopes)
    end
  end
end
