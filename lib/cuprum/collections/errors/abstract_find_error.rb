# frozen_string_literal: true

require 'cuprum/collections/errors'
require 'cuprum/collections/relations/parameters'

module Cuprum::Collections::Errors
  # Abstract base class for failed query errors.
  class AbstractFindError < Cuprum::Error # rubocop:disable Metrics/ClassLength
    COLLECTION_KEYWORDS = %i[
      collection
      collection_name
      entity_class
      name
      qualified_name
    ].freeze
    private_constant :COLLECTION_KEYWORDS

    QUERYING_KEYWORDS = %i[
      attribute_name
      attribute_value
      attributes
      primary_key
      query
    ].freeze
    private_constant :QUERYING_KEYWORDS

    VALID_PARAMETERS = %i[entity_class name qualified_name].freeze
    private_constant :VALID_PARAMETERS

    class << self
      # Resolves the details about the queried collection.
      #
      # @param params [Hash] the parameters to resolve.
      #
      # @return [Hash] the collection details.
      def resolve_collection(**params) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        if params[:collection].is_a?(Cuprum::Collections::Collection)
          return collection_details(params[:collection])
        elsif collection_name?(params[:collection])
          return { 'name' => params[:collection].to_s }
        elsif collection_name?(params[:collection_name])
          # @deprecated 0.6.0
          tools.core_tools.deprecate(
            ':collection_name parameter is deprecated',
            message: 'Use the :name parameter instead.'
          )

          return { 'name' => params[:collection_name].to_s }
        elsif VALID_PARAMETERS.any? { |key| params.key?(key) }
          return Cuprum::Collections::Relations::Parameters
              .resolve_parameters(params)
              .slice(*VALID_PARAMETERS)
              .to_h { |key, value| [key.to_s, value.to_s] }
        end

        raise ArgumentError, "collection, name or entity class can't be blank"
      end

      private

      def collection_details(collection)
        entity_class = collection.entity_class
        entity_class = entity_class.name if entity_class.is_a?(Class)

        {
          'entity_class'   => entity_class,
          'name'           => collection.name,
          'qualified_name' => collection.qualified_name
        }
      end

      def collection_name?(value)
        return false unless value.is_a?(String) || value.is_a?(Symbol)

        !value.to_s.empty?
      end

      def tools
        SleepingKingStudios::Tools::Toolbelt.instance
      end
    end

    # @overload initialize(attribute_name:, attribute_value:, name:, primary_key: false)
    #   @param attribute_name [String] the name of the queried attribute.
    #   @param attribute_value [Object] the value of the queried attribute.
    #   @param name [String] the name of the collection.
    #   @param primary_key [true, false] indicates that the queried attribute is
    #     the primary key for the collection.
    #
    # @overload initialize(attributes:, name:)
    #   @param attributes [Hash<String=>Object>] the queried attributes.
    #   @param name [String] the name of the collection.
    #
    # @overload initialize(query:, name:)
    #   @param name [String] the name of the collection.
    #   @param query [Cuprum::Collections::Query] The performed query.
    def initialize(**params) # rubocop:disable Metrics/MethodLength
      @collection      = self.class.resolve_collection(**params)
      @collection_name = @collection['name']
      @primary_key     = false

      resolve_options(**params.except(*COLLECTION_KEYWORDS))

      super(
        attribute_name:,
        attribute_value:,
        attributes:,
        message:         generate_message,
        scope:
      )
    end

    # @return [String] the name of the queried attribute, if any.
    attr_reader :attribute_name

    # @return [Object] the value of the queried attribute, if any.
    attr_reader :attribute_value

    # @return [Hash<String=>Object>] The queried attributes.
    attr_reader :attributes

    # @return [Hash] the resolved collection details.
    attr_reader :collection

    # @return [Cuprum::Collections::Scopes::Base] the query scope, if any.
    attr_reader :scope

    # @return [String] the name of the collection.
    #
    # @deprecated 0.6.0
    def collection_name
      tools.core_tools.deprecate(
        '#collection_name is deprecated',
        message: 'Use the #collection method instead.'
      )

      collection['name']
    end

    # @return [Array<Array>] the details of the query, in scope format.
    def details # rubocop:disable Metrics/MethodLength
      if attribute_name
        criteria = [[attribute_name, :equal, attribute_value]]

        { 'type' => :criteria, 'criteria' => criteria }
      elsif attributes
        criteria =
          attributes
            .map { |attr_name, attr_value| [attr_name, :equal, attr_value] }

        { 'type' => :criteria, 'criteria' => criteria }
      elsif scope
        scope
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
        'collection' => collection,
        'details'    => details
      }.merge(find_data)
    end

    def entity_name
      titleize(tools.str.singularize(collection['name']))
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
          "#{' (primary key)' if primary_key?}"
      elsif attributes
        "#{core_message} with attributes #{attributes.inspect}"
      elsif scope
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
      @scope  = options.delete(:query)&.scope

      validate_keywords(extra_keywords: options.keys)
    end

    def resolve_options(**options) # rubocop:disable Metrics/MethodLength
      if options[:attribute_name] && options.key?(:attribute_value)
        resolve_attribute_options(**options)
      elsif options[:attributes]
        resolve_attributes_options(**options)
      elsif options[:query]
        resolve_query_options(**options)
      else
        raise ArgumentError,
          'missing keywords :attribute_name, :attribute_value, :attributes, ' \
          'or :query'
      end
    end

    def titleize(string)
      tools.str.underscore(string).split('_').map(&:capitalize).join(' ')
    end

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
    end

    def validate_keywords(extra_keywords:) # rubocop:disable Metrics/MethodLength
      return if extra_keywords.empty?

      ambiguous_keywords = extra_keywords & QUERYING_KEYWORDS

      if ambiguous_keywords.empty?
        raise ArgumentError,
          "unknown keyword#{'s' unless extra_keywords.size == 1} " \
          "#{extra_keywords.map(&:inspect).join(', ')}"
      else
        raise ArgumentError,
          "ambiguous keyword#{'s' unless extra_keywords.size == 1} " \
          "#{ambiguous_keywords.map(&:inspect).join(', ')}"
      end
    end
  end
end
