# frozen_string_literal: true

require 'cuprum/collections/scopes'

module Cuprum::Collections::Scopes
  # Functionality for implementing a none scope, which returns no data.
  module None
    # @overload and(hash = nil, &block)
    #   Returns the none scope.
    #
    # @overload and(scope)
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

    # @overload or(hash = nil, &block)
    #   Returns the none scope.
    #
    # @overload or(scope)
    #   Returns the none scope.
    def or(*args, &block)
      return super if scope?(args.first)

      builder.build(*args, &block)
    end

    # @overload not(hash = nil, &block)
    #   Returns the none scope.
    #
    # @overload not(scope)
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

      builder.transform_scope(scope: scope)
    end
  end
end
