# frozen_string_literal: true

require 'cuprum/collections/scopes'
require 'cuprum/collections/scopes/composition'

module Cuprum::Collections::Scopes
  # Abstract class representing a set of filters for a query.
  class Base
    include Cuprum::Collections::Scopes::Composition

    def initialize(**); end

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
  end
end

require 'cuprum/collections/scopes/builder'
