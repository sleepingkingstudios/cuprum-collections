# frozen_string_literal: true

require 'cuprum/collections/scopes/composition'

module Cuprum::Collections::Scopes::Composition
  # Defines composition behavior for disjunction scopes.
  module Disjunction
    # (see Cuprum::Collections::Scopes::Composition#or)
    def or(*args, &block)
      return or_disjuncton_scope(args.first) if disjunction_scope?(args.first)

      with_scopes([*scopes, builder.build(*args, &block)])
    end

    private

    def or_disjuncton_scope(scope)
      scopes = scope.scopes.map do |inner|
        builder.transform_scope(scope: inner)
      end

      with_scopes([*self.scopes, *scopes])
    end
  end
end
