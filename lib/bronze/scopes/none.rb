# frozen_string_literal: true

require 'bronze/scopes'

module Bronze::Scopes
  # Functionality for implementing a none scope, which returns no data.
  module None
    # @overload and(hash = nil, &block)
    #   Returns the none scope.
    #
    # @overload and(scope)
    #   Returns the none scope.
    def and(*, &)
      self
    end
    alias where and

    # @return [Boolean] false.
    def empty?
      false
    end

    # @return [Bronze::Scopes::All] an all scope for the current collection.
    def invert
      builder.build_all_scope
    end

    # @overload or(hash = nil, &block)
    #   Returns the none scope.
    #
    # @overload or(scope)
    #   Returns the none scope.
    def or(*args, &)
      return super if scope?(args.first)

      builder.build(*args, &)
    end

    # @overload not(hash = nil, &block)
    #   Returns the none scope.
    #
    # @overload not(scope)
    #   Returns the none scope.
    def not(*, &)
      self
    end

    # (see Bronze::Scopes::Base#type)
    def type
      :none
    end

    private

    def or_scope(scope)
      return self if scope.empty?

      builder.transform_scope(scope:)
    end
  end
end
