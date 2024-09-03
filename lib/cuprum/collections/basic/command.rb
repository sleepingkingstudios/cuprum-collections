# frozen_string_literal: true

require 'stannum/constraints/types/array_type'

require 'cuprum/collections/basic'

module Cuprum::Collections::Basic
  # Abstract base class for basic collection commands.
  class Command < Cuprum::Collections::CollectionCommand
    # @return [Array<Hash>] the current data in the collection.
    def data
      collection.data
    end

    # @return [Stannum::Constraints::Base, nil] the default contract for
    #   validating items in the collection.
    def default_contract
      @default_contract ||= collection.default_contract
    end

    private

    def validate_entity(value, as: 'entity') # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      return error_message_for(as:, expected: Hash) unless value.is_a?(Hash)

      return [] if value.empty?

      validator = tools.assertions.aggregator_class.new

      value.each_key do |key|
        unless key.nil? || key.is_a?(String)
          validator << error_message_for(
            as:       "#{as}[#{key.inspect}] key",
            expected: String
          )

          next
        end

        validator.validate_presence(key, as: "#{as}[#{key.inspect}] key")
      end

      validator.each.to_a
    end
  end
end
