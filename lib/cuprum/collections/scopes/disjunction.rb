# frozen_string_literal: true

require 'cuprum/collections/scopes'
require 'cuprum/collections/scopes/container'

module Cuprum::Collections::Scopes
  # Functionality for implementing a logical OR scope.
  module Disjunction
    include Cuprum::Collections::Scopes::Container

    # (see Cuprum::Collections::Scopes::Composition#or)
    def or(*args, &block)
      return super if scope?(args.first)

      scope = builder.build(*args, &block)

      with_scopes([*scopes, scope])
    end

    # (see Cuprum::Collections::Scopes::Base#type)
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
      with_scopes([*scopes, builder.transform_scope(scope: scope)])
    end
  end
end
