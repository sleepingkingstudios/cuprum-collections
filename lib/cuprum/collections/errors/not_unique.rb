# frozen_string_literal: true

require 'cuprum/error'

require 'cuprum/collections/errors'

module Cuprum::Collections::Errors
  # Returned when a unique find command does finds multiple items.
  class NotUnique < Cuprum::Error
    # Short string used to identify the type of error.
    TYPE = 'cuprum.collections.errors.not_unique'

    # @param collection_name [String, Symbol] The name of the collection.
    # @param primary_key_name [String, Symbol] The name of the primary key
    #   attribute.
    # @param primary_key_values [Object, Array] The expected values of the
    #   primary key attribute.
    def initialize(collection_name:, primary_key_name:, primary_key_values:)
      @collection_name    = collection_name
      @primary_key_name   = primary_key_name
      @primary_key_values = Array(primary_key_values)

      super(message: default_message)
    end

    # @return [String, Symbol] the name of the collection.
    attr_reader :collection_name

    # @return [String, Symbol] the name of the primary key attribute.
    attr_reader :primary_key_name

    # @return [Array] The expected values of the primary key attribute.
    attr_reader :primary_key_values

    # @return [Hash] a serializable hash representation of the error.
    def as_json
      {
        'data'    => {
          'collection_name'    => collection_name,
          'primary_key_name'   => primary_key_name,
          'primary_key_values' => primary_key_values
        },
        'message' => message,
        'type'    => type
      }
    end

    private

    def default_message
      primary_keys = primary_key_values.map(&:inspect).join(', ')

      "Duplicate #{entity_name} found with #{primary_key_name} #{primary_keys}"
    end

    def entity_name
      entity_name = collection_name
      entity_name = tools.str.pluralize(entity_name)

      titleize(entity_name)
    end

    def titleize(string)
      tools.str.underscore(string).split('_').map(&:capitalize).join(' ')
    end

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
    end
  end
end
