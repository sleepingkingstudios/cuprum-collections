# frozen_string_literal: true

require 'cuprum/collections/basic/scopes'
require 'cuprum/collections/scopes/base'

module Cuprum::Collections::Basic::Scopes
  # Abstract class representing a set of filters for a basic query.
  class Base < Cuprum::Collections::Scopes::Base
    # Filters the provided data.
    def call(data:)
      raise ArgumentError, 'data must be an Array' unless data.is_a?(Array)

      data.select { |item| match?(item:) }
    end

    # Returns true if the provided item matches the scope.
    def match?(item:)
      raise ArgumentError, 'item must be a Hash' unless item.is_a?(Hash)

      true
    end
    alias matches? match?

    private

    def builder
      Cuprum::Collections::Basic::Scopes::Builder.instance
    end
  end
end

require 'cuprum/collections/basic/scopes/builder'
