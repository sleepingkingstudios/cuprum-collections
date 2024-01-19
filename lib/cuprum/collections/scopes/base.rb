# frozen_string_literal: true

require 'cuprum/collections/scopes'
require 'cuprum/collections/scopes/composition'

module Cuprum::Collections::Scopes
  # Abstract class representing a set of filters for a query.
  class Base
    include Cuprum::Collections::Scopes::Composition

    def initialize(**); end

    # @param other [Object] the object to compare.
    #
    # @return [Boolean] true if the other object is a scope with matching type;
    #   otherwise false.
    def ==(other)
      return false unless other.is_a?(Cuprum::Collections::Scopes::Base)

      other.type == type
    end

    # :nocov:

    # @private
    #
    # Generates a string representation of the scope.
    def debug
      debug_class_name(self)
    end
    # :nocov:

    # @return [Boolean] false.
    def empty?
      false
    end

    # @return [Symbol] the scope type.
    def type
      :abstract
    end

    private

    def builder
      Cuprum::Collections::Scopes::Builder.instance
    end

    # :nocov:
    def debug_class_name(scope)
      name     = scope.class.name.sub(/\ACuprum::Collections::/, '')
      segments =
        name.split(/(::)?Scopes(::)?/).reject { |s| s.empty? || s == '::' }

      segments.join('::')
    end
    # :nocov:
  end
end

require 'cuprum/collections/scopes/builder'
