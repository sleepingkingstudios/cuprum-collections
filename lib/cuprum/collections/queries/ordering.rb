# frozen_string_literal: true

require 'cuprum/collections/queries'

module Cuprum::Collections::Queries
  # Namespace for legacy order validation.
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
      def normalize(*attributes)
        qualified = attributes.last.is_a?(Hash) ? attributes.pop : {}
        qualified = normalize_order_hash(qualified)

        validate_order_attributes(attributes)

        attributes
          .each
          .with_object({}) { |attribute, hsh| hsh[attribute.intern] = :asc }
          .merge(qualified)
          .tap { |hsh| validate_order_normalized(hsh) }
      end

      private

      def invalid_order_error
        'order must be a list of attribute names and/or a hash of attribute' \
        ' names with values :asc or :desc'
      end

      def normalize_order_hash(hsh)
        hsh.each.with_object({}) do |(key, value), normalized|
          unless valid_order_hash_key?(key)
            raise InvalidOrderError, invalid_order_error, caller(2..-1)
          end

          normalized[key.intern] = normalize_order_hash_value(value)
        end
      end

      def normalize_order_hash_value(value)
        value = value.downcase if value.is_a?(String)

        ORDER_HASH_VALUES.fetch(value.is_a?(String) ? value.intern : value) do
          raise InvalidOrderError, invalid_order_error, caller(3..-1)
        end
      end

      def valid_order_hash_key?(key)
        (key.is_a?(String) || key.is_a?(Symbol)) && !key.to_s.empty?
      end

      def validate_order_attributes(attributes)
        return if attributes.all? do |item|
          (item.is_a?(String) || item.is_a?(Symbol)) && !item.to_s.empty?
        end

        raise InvalidOrderError, invalid_order_error, caller(2..-1)
      end

      def validate_order_normalized(hsh)
        return unless hsh.empty?

        raise InvalidOrderError, invalid_order_error, caller(2..-1)
      end
    end
  end
end
