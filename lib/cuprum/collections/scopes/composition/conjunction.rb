# frozen_string_literal: true

require 'cuprum/collections/scopes/composition'

module Cuprum::Collections::Scopes::Composition
  # Defines composition behavior for conjunction scopes.
  module Conjunction
    include Cuprum::Collections::Scopes::Composition

    # (see Cuprum::Collections::Scopes::Composition#and)
    def and(*args, &block)
      return and_conjunction_scope(args.first) if conjunction_scope?(args.first)

      with_scopes([*scopes, builder.build(*args, &block)])
    end
    alias where and

    # (see Cuprum::Collections::Scopes::Composition#not)
    def not(*args, &block)
      return not_conjunction_scope(args.first) if conjunction_scope?(args.first)

      scope    = builder.build(*args, &block)
      inverted = builder.build_negation_scope(scopes: [scope], safe: false)

      with_scopes([*scopes, inverted])
    end

    private

    def and_conjunction_scope(scope)
      scopes = scope.scopes.map do |inner|
        builder.transform_scope(scope: inner)
      end

      with_scopes([*self.scopes, *scopes])
    end

    def not_conjunction_scope(scope)
      scopes = scope.scopes.map do |inner|
        builder.transform_scope(scope: inner)
      end
      inverted = builder.build_negation_scope(scopes: scopes, safe: false)

      with_scopes([*self.scopes, inverted])
    end
  end
end
