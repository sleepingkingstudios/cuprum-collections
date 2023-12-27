# frozen_string_literal: true

require 'cuprum/collections/basic'
require 'cuprum/collections/scope'

module Cuprum::Collections::Basic
  # Abstract class representing a set of filters for a basic query.
  class Scope < Cuprum::Collections::Scope
    # Filters the provided data.
    def call(data:)
      raise ArgumentError, 'data must be an Array' unless data.is_a?(Array)

      data.select { |item| match?(item: item) }
    end

    # Returns true if the provided item matches the scope.
    def match?(item:)
      raise ArgumentError, 'item must be a Hash' unless item.is_a?(Hash)

      true
    end
    alias matches? match?
  end
end
