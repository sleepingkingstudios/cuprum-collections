# frozen_string_literal: true

require 'cuprum/collections/constraints/ordering'
require 'cuprum/collections/queries'

module Cuprum::Collections::Queries
  # Functionality around validating and normalizing query sort orderings.
  module Ordering
    # Exception class for handling invalid order keywords.
    class InvalidOrderError < ArgumentError; end

    ORDER_HASH_VALUES = {
      asc:        :asc,
      ascending:  :asc,
      desc:       :desc,
      descending: :desc
    }.freeze
    private_constant :ORDER_HASH_VALUES

    class << self
      # @overload normalize(*attributes, ordering_hash = nil)
      #   Converts the given sort order into a hash with standard values.
      #
      #   @param attributes [Array<String, Symbol>] The attribute names to sort
      #     by, in ascending direction, and in order of importance.
      #   @param ordering_hash [Hash] An optional ordering hash, with keys that
      #     are valid attribute names and values that are valid sort directions.
      #
      #   @return [Hash] the normalized sort ordering.
      #
      #   @raise InvalidOrderError if any of the attributes are invalid
      #     attribute names.
      #   @raise InvalidOrderError if any of the hash keys are invalid attribute
      #     names, or any of the hash values are invalid sort directions.
      def normalize(*attributes)
        attributes = attributes.flatten if attributes.first.is_a?(Array)

        validate_ordering!(attributes)

        qualified = attributes.last.is_a?(Hash) ? attributes.pop : {}
        qualified = normalize_order_hash(qualified)

        attributes
          .each
          .with_object({}) { |attribute, hsh| hsh[attribute.intern] = :asc }
          .merge(qualified)
      end

      private

      def normalize_order_hash(hsh)
        hsh.each.with_object({}) do |(key, value), normalized|
          normalized[key.intern] = normalize_order_hash_value(value)
        end
      end

      def normalize_order_hash_value(value)
        value = value.downcase if value.is_a?(String)

        ORDER_HASH_VALUES.fetch(value.is_a?(String) ? value.intern : value)
      end

      def ordering_constraint
        Cuprum::Collections::Constraints::Ordering.instance
      end

      def validate_ordering!(attributes)
        return if ordering_constraint.matches?(attributes)

        raise InvalidOrderError,
          'order must be a list of attribute names and/or a hash of ' \
          'attribute names with values :asc or :desc'
      end
    end
  end
end
