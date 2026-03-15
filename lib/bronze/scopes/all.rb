# frozen_string_literal: true

require 'bronze/scopes'

module Bronze::Scopes
  # Functionality for implementing an all scope, which returns all data.
  module All
    # @overload and(hash = nil, &block)
    #   Parses the hash or block and returns the parsed scope.
    #
    #   @see Bronze::Scopes::Criteria::Parser#parse.
    #
    # @overload and(scope)
    #   Returns the given scope.
    def and(*args, &)
      return self if scope?(args.first) && args.first.empty?

      builder.build(*args, &)
    end
    alias where and

    # @return [Boolean] false.
    def empty?
      false
    end

    # @return [Bronze::Scopes::None] a none scope for the current collection.
    def invert
      builder.build_none_scope
    end

    # @overload or(hash = nil, &block)
    #   Parses the hash or block and returns the parsed scope.
    #
    #   @see Bronze::Scopes::Criteria::Parser#parse.
    #
    # @overload or(scope)
    #   Returns the given scope.
    def or(*args, &)
      return self if scope?(args.first) && args.first.empty?

      builder.build(*args, &)
    end

    # (see Bronze::Scopes::Base#type)
    def type
      :all
    end
  end
end
