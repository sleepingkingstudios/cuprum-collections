# frozen_string_literal: true

require 'bronze/scopes'
require 'bronze/scopes/composition'

module Bronze::Scopes
  # Abstract class representing a set of filters for a query.
  class Base
    include Bronze::Scopes::Composition

    # Exception raised when inverting an uninvertible scope.
    class UninvertibleScopeException < StandardError; end

    def initialize(**); end

    # @param other [Object] the object to compare.
    #
    # @return [Boolean] true if the other object is a scope with matching type;
    #   otherwise false.
    def ==(other)
      return false unless other.is_a?(Bronze::Scopes::Base)

      other.type == type
    end

    # @return [Hash{String=>Object}] a JSON-compatible representation of the
    #   scope.
    def as_json
      { 'type' => type }
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

    # Generates and returns an inverted copy of the scope.
    #
    # @raise [UninvertibleScopeException] if the scope does not implement
    #   #invert.
    def invert
      raise UninvertibleScopeException,
        "Scope class #{self.class.name} does not implement #invert"
    end

    # @return [Symbol] the scope type.
    def type
      :abstract
    end

    private

    def builder
      Bronze::Scopes::Builder.instance
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
