# frozen_string_literal: true

require 'cuprum/collections/scopes'
require 'cuprum/collections/scopes/container'

module Cuprum::Collections::Scopes
  # Functionality for implementing a logical NAND scope.
  module Negation
    include Cuprum::Collections::Scopes::Container

    # (see Cuprum::Collections::Scopes::Composition#and)
    def and(*args, &block)
      return self if empty_scope?(args.first)

      return super unless negation_scope?(args.first)

      scopes = args.first.scopes.map do |scope|
        builder.transform_scope(scope: scope)
      end

      with_scopes([*self.scopes, *scopes])
    end
    alias where and

    # (see Cuprum::Collections::Scopes::Composition#not)
    def not(*args, &block)
      return self if empty_scope?(args.first)

      return super unless negation_scope?(args.first)

      scopes = args.first.scopes.map do |scope|
        builder.transform_scope(scope: scope)
      end

      return scopes.first if scopes.size == 1

      builder.build_conjunction_scope(scopes: scopes)
    end

    # (see Cuprum::Collections::Scopes::Base#type)
    def type
      :negation
    end
  end
end
