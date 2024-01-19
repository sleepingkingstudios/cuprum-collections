# frozen_string_literal: true

require 'cuprum/collections/scopes'
require 'cuprum/collections/scopes/container'

module Cuprum::Collections::Scopes
  # Functionality for implementing a logical OR scope.
  module Disjunction
    include Cuprum::Collections::Scopes::Container

    # (see Cuprum::Collections::Scopes::Composition#or)
    def or(*args, &block)
      return self if empty_scope?(args.first)

      return or_disjunction_scope(args.first) if disjunction_scope?(args.first)

      with_scopes([*scopes, builder.build(*args, &block)])
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
  end
end
