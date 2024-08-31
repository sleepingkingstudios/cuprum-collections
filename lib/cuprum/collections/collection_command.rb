# frozen_string_literal: true

require 'cuprum/parameter_validation'

require 'cuprum/collections'
require 'cuprum/collections/errors/invalid_parameters'

module Cuprum::Collections
  # Abstract base class for commands implementing collection actions.
  class CollectionCommand < Cuprum::Command
    include Cuprum::ParameterValidation

    # @param collection [Cuprum::Collections::Collection] the collection to
    #   which the command belongs.
    def initialize(collection:)
      super()

      @collection = collection
    end

    # @return [Cuprum::Collections::Collection] the collection to which the
    #   command belongs.
    attr_reader :collection

    # @return [String] the name of the relation.
    def name
      @name ||= collection.name
    end
    alias collection_name name

    # @return [String] the name of the primary key attribute. Defaults to 'id'.
    def primary_key_name
      @primary_key_name ||= collection.primary_key_name
    end

    # @return [Class, Stannum::Constraint] the type of the primary key
    #   attribute. Defaults to Integer.
    def primary_key_type
      @primary_key_type ||= collection.primary_key_type
    end

    # A new Query instance, used for querying against the collection data.
    #
    # @return [Object] the query.
    def query
      collection.query
    end

    # @returnb [String] the name of an entity in the collection.
    def singular_name
      @singular_name ||= collection.singular_name
    end
    alias member_name singular_name

    private

    def error_message_for(message = nil, as:, expected:)
      tools.assertions.error_message_for(
        message || 'sleeping_king_studios.tools.assertions.instance_of',
        as:,
        expected:
      )
    end

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
    end

    def validate_attributes(value, as: 'attributes')
      return error_message_for(as:, expected: Hash) unless value.is_a?(Hash)

      return [] if value.empty?

      validator = tools.assertions.aggregator_class.new

      value.each_key do |key|
        validator.validate_name(
          key,
          as: "#{as}[#{key.inspect}] key"
        )
      end

      validator.each.to_a
    end

    def validate_primary_key(value, as: nil)
      return nil if primary_key_type.nil?

      if primary_key_type.is_a?(Stannum::Constraints::Base)
        match, errors = primary_key_type.match(value)

        return match ? nil : "#{as || primary_key_name} #{errors.summary}"
      end

      return nil if value.is_a?(primary_key_type)

      error_message_for(as: as || primary_key_name, expected: primary_key_type)
    end

    def validate_primary_keys(primary_keys, as: 'value')
      unless primary_keys.is_a?(Array)
        return error_message_for(as:, expected: Array)
      end

      messages = []

      primary_keys.each.with_index do |item, index|
        message = validate_primary_key(item, as: "#{as}[#{index}]")

        messages << message if message
      end

      messages
    end
  end
end
