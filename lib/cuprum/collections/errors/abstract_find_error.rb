# frozen_string_literal: true

require 'cuprum/collections/errors'

module Cuprum::Collections::Errors
  # Abstract base class for failed query errors.
  class AbstractFindError < Cuprum::Error # rubocop:disable Metrics/ClassLength
    PERMITTED_KEYWORDS = %i[
      attribute_name
      attribute_value
      attributes
      primary_key
      query
    ].freeze
    private_constant :PERMITTED_KEYWORDS

    # @overload initialize(attribute_name:, attribute_value:, collection_name:, primary_key: false) # rubocop:disable Layout/LineLength
    #   @param attribute_name [String] The name of the queried attribute.
    #   @param attribute_value [Object] The value of the queried attribute.
    #   @param collection_name [String] The name of the collection.
    #   @param primary_key [true, false] Indicates that the queried attribute is
    #     the primary key for the collection.
    #
    # @overload initialize(attributes:, collection_name:)
    #   @param attributes [Hash<String=>Object>] The queried attributes.
    #   @param collection_name [String] The name of the collection.
    #
    # @overload initialize(query:, collection_name:)
    #   @param collection_name [String] The name of the collection.
    #   @param query [Cuprum::Collections::Query] The performed query.
    def initialize(collection_name:, **options) # rubocop:disable Metrics/MethodLength
      @collection_name = collection_name
      @primary_key     = false

      resolve_options(**options)

      super(
        attribute_name:  attribute_name,
        attribute_value: attribute_value,
        attributes:      attributes,
        collection_name: collection_name,
        message:         generate_message,
        query:           query&.criteria
      )
    end

    # @return [String] the name of the queried attribute, if any.
    attr_reader :attribute_name

    # @return [Object] the value of the queried attribute, if any.
    attr_reader :attribute_value

    # @return [Hash<String=>Object>] The queried attributes.
    attr_reader :attributes

    # @return [String] the name of the collection.
    attr_reader :collection_name

    # @return [Cuprum::Collections::Query] the performed query, if any.
    attr_reader :query

    # @return [Array<Array>] the details of the query, in query criteria format.
    def details
      if attribute_name
        [[attribute_name, :equal, attribute_value]]
      elsif attributes
        attributes
          .map { |attr_name, attr_value| [attr_name, :equal, attr_value] }
      elsif query
        query.criteria
      end
    end

    # @return [true, false] indicates that the queried attribute is the primary
    #   key for the collection.
    def primary_key?
      @primary_key
    end

    private

    def as_json_data
      {
        'collection_name' => collection_name,
        'details'         => details
      }.merge(find_data)
    end

    def entity_name
      titleize(tools.str.singularize(collection_name))
    end

    def find_data # rubocop:disable Metrics/MethodLength
      if attribute_name
        {
          'attribute_name'  => attribute_name,
          'attribute_value' => attribute_value,
          'primary_key'     => primary_key?
        }
      elsif attributes
        hsh = tools.hash_tools.convert_keys_to_strings(attributes)

        { 'attributes' => hsh }
      else
        {}
      end
    end

    def generate_message
      core_message = "#{entity_name} #{message_fragment}"

      if attribute_name
        "#{core_message} with #{attribute_name.inspect} " \
          "#{attribute_value.inspect}" \
          "#{primary_key? ? ' (primary key)' : ''}"
      elsif attributes
        "#{core_message} with attributes #{attributes.inspect}"
      elsif query
        "#{core_message} matching the query"
      end
    end

    def message_fragment
      'query failed'
    end

    def resolve_attribute_options(**options)
      options          = options.dup
      @attribute_name  = options.delete(:attribute_name)
      @attribute_value = options.delete(:attribute_value)
      @primary_key     = options.delete(:primary_key) || false

      validate_keywords(extra_keywords: options.keys)
    end

    def resolve_attributes_options(**options)
      options     = options.dup
      @attributes = options.delete(:attributes)

      validate_keywords(extra_keywords: options.keys)
    end

    def resolve_query_options(**options)
      options = options.dup
      @query  = options.delete(:query)

      validate_keywords(extra_keywords: options.keys)
    end

    def resolve_options(**options) # rubocop:disable Metrics/MethodLength
      if options[:primary_key_name] && options[:primary_key_values]
        resolve_primary_key_options(**options)
      elsif options[:attribute_name] && options.key?(:attribute_value)
        resolve_attribute_options(**options)
      elsif options[:attributes]
        resolve_attributes_options(**options)
      elsif options[:query]
        resolve_query_options(**options)
      else
        raise ArgumentError,
          'missing keywords :attribute_name, :attribute_value or :attributes ' \
          'or :query'
      end
    end

    def resolve_primary_key_options(**options) # rubocop:disable Metrics/MethodLength
      values = Array(options[:primary_key_values])

      unless values.size == 1
        raise ArgumentError,
          'deprecated mode does not support empty or multiple attribute values'
      end

      SleepingKingStudios::Tools::CoreTools
        .instance
        .deprecate(
          'NotFound.new(primary_key_name:, primary_key_values:)',
          message: 'use NotFound.new(attribute_name:, attribute_value:)'
        )

      @attribute_name  = options[:primary_key_name]
      @attribute_value = values.first
      @primary_key     = true
    end

    def titleize(string)
      tools.str.underscore(string).split('_').map(&:capitalize).join(' ')
    end

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
    end

    def validate_keywords(extra_keywords:) # rubocop:disable Metrics/MethodLength
      return if extra_keywords.empty?

      ambiguous_keywords = extra_keywords & PERMITTED_KEYWORDS

      if ambiguous_keywords.empty?
        raise ArgumentError,
          "unknown keyword#{extra_keywords.size == 1 ? '' : 's'} " \
          "#{extra_keywords.map(&:inspect).join(', ')}"
      else
        raise ArgumentError,
          "ambiguous keyword#{extra_keywords.size == 1 ? '' : 's'} " \
          "#{ambiguous_keywords.map(&:inspect).join(', ')}"
      end
    end
  end
end
