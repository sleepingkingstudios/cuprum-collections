# frozen_string_literal: true

require 'cuprum/collections/scopes'
require 'cuprum/collections/scopes/container'

module Cuprum::Collections::Scopes
  # Functionality for implementing a logical AND scope.
  module Conjunction
    include Cuprum::Collections::Scopes::Container

    # (see Cuprum::Collections::Scopes::Composition#and)
    def and(*args, &block)
      return self if empty_scope?(args.first)

      return and_conjunction_scope(args.first) if conjunction_scope?(args.first)

      with_scopes([*scopes, builder.build(*args, &block)])
    end
    alias where and

    # (see Cuprum::Collections::Scopes::Composition#not)
    def not(*args, &block)
      return self if empty_scope?(args.first)

      return not_conjunction_scope(args.first) if conjunction_scope?(args.first)

      return not_negation_scope(args.first) if negation_scope?(args.first)

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

    def not_conjunction_scope(scope)
      scopes = scope.scopes.map do |inner|
        builder.transform_scope(scope: inner)
      end
      inverted = builder.build_negation_scope(scopes: scopes, safe: false)

      with_scopes([*self.scopes, inverted])
    end

    def not_negation_scope(scope)
      scopes = scope.scopes.map do |inner|
        builder.transform_scope(scope: inner)
      end

      with_scopes([*self.scopes, *scopes])
    end
  end
end
