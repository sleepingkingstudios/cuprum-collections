# frozen_string_literal: true

require 'cuprum/collections/scopes'

module Cuprum::Collections::Scopes
  # Functionality for implementing a none scope, which returns no data.
  module None
    # @override and(hash = nil, &block)
    #   Returns the none scope.
    #
    # @override and(scope)
    #   Returns the none scope.
    def and(*, &_)
      self
    end
    alias where and

    # @return [Boolean] false.
    def empty?
      false
    end

    # @return [Cuprum::Collections::Scopes::All] an all scope for the current
    #   collection.
    def invert
      builder.build_all_scope
    end

    # @override or(hash = nil, &block)
    #   Returns the none scope.
    #
    # @override or(scope)
    #   Returns the none scope.
    def or(*args, &block)
      return super if scope?(args.first)

      builder.build(*args, &block)
    end

    # @override not(hash = nil, &block)
    #   Returns the none scope.
    #
    # @override not(scope)
    #   Returns the none scope.
    def not(*, &_)
      self
    end

    # (see Cuprum::Collections::Scopes::Base#type)
    def type
      :none
    end

    private

    def or_scope(scope)
      return self if scope.empty?

      scope
    end
  end
end
