# frozen_string_literal: true

require 'cuprum/collections/scopes'
require 'cuprum/collections/scopes/container'

module Cuprum::Collections::Scopes
  # Functionality for implementing a logical NAND scope.
  module Negation
    include Cuprum::Collections::Scopes::Container

    # (see Cuprum::Collections::Scopes::Base#type)
    def type
      :negation
    end

    private

    def and_negation_scope(scope)
      scopes = scope.scopes.map do |inner|
        builder.transform_scope(scope: inner)
      end

      with_scopes([*self.scopes, *scopes])
    end
  end
end
