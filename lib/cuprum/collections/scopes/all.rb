# frozen_string_literal: true

require 'cuprum/collections/scopes'

module Cuprum::Collections::Scopes
  # Functionality for implementing an all scope, which returns all data.
  module All
    # @overload and(hash = nil, &block)
    #   Parses the hash or block and returns the parsed scope.
    #
    #   @see Cuprum::Collections::Scopes::Criteria::Parser#parse.
    #
    # @overload and(scope)
    #   Returns the given scope.
    def and(*args, &block)
      return self if scope?(args.first) && args.first.empty?

      builder.build(*args, &block)
    end
    alias where and

    # @return [Boolean] false.
    def empty?
      false
    end

    # @return [Cuprum::Collections::Scopes::None] a none scope for the current
    #   collection.
    def invert
      builder.build_none_scope
    end

    # @overload or(hash = nil, &block)
    #   Parses the hash or block and returns the parsed scope.
    #
    #   @see Cuprum::Collections::Scopes::Criteria::Parser#parse.
    #
    # @overload or(scope)
    #   Returns the given scope.
    def or(*args, &block)
      return self if scope?(args.first) && args.first.empty?

      builder.build(*args, &block)
    end

    # (see Cuprum::Collections::Scopes::Base#type)
    def type
      :all
    end
  end
end
