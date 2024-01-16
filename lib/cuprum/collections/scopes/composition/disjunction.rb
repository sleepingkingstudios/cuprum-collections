# frozen_string_literal: true

require 'cuprum/collections/scopes/composition'

module Cuprum::Collections::Scopes::Composition
  # Defines composition behavior for disjunction scopes.
  module Disjunction
    # (see Cuprum::Collections::Scopes::Composition#or)
    def or(*args, &block)
      scopes =
        if args.first.is_a?(Cuprum::Collections::Scopes::Base) &&
           args.first.type == :disjunction
          args.first.scopes.map do |scope|
            builder.transform_scope(scope: scope)
          end
        else
          [builder.build(*args, &block)]
        end

      with_scopes([*self.scopes, *scopes])
    end
  end
end
