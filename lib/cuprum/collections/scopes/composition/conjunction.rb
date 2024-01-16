# frozen_string_literal: true

require 'cuprum/collections/scopes/composition'

module Cuprum::Collections::Scopes::Composition
  # Defines composition behavior for conjunction scopes.
  module Conjunction
    include Cuprum::Collections::Scopes::Composition

    # (see Cuprum::Collections::Scopes::Composition#and)
    def and(*args, &block)
      scopes =
        if args.first.is_a?(Cuprum::Collections::Scopes::Base) &&
           args.first.type == :conjunction
          args.first.scopes.map do |scope|
            builder.transform_scope(scope: scope)
          end
        else
          [builder.build(*args, &block)]
        end

      with_scopes([*self.scopes, *scopes])
    end
    alias where and

    # (see Cuprum::Collections::Scopes::Composition#not)
    def not(...)
      scope    = builder.build(...)
      inverted = builder.build_negation_scope(scopes: [scope])

      with_scopes([*scopes, inverted])
    end
  end
end
