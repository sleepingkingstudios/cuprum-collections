# frozen_string_literal: true

require 'cuprum/collections/relations'

module Cuprum::Collections::Relations
  # Methods for resolving a relations's naming and entity class from options.
  module Parameters # rubocop:disable Metrics/ModuleLength
    PARAMETER_KEYS = %i[entity_class name qualified_name].freeze
    private_constant :PARAMETER_KEYS

    class << self # rubocop:disable Metrics/ClassLength
      # @overload resolve_parameters(entity_class: nil, singular_name: nil, name: nil, qualified_name: nil)
      #   Helper method for resolving a Relation's required parameters.
      #
      #   The returned Hash will define the :entity_class, :singular_name,
      #   :name, and :qualified_name keys.
      #
      #   @param entity_class [Class, String] the class of entity represented
      #     by the relation.
      #   @param singular_name [String] the name of an entity in the relation.
      #   @param name [String] the name of the relation.
      #   @param qualified_name [String] a scoped name for the relation.
      #
      #   @return [Hash] the resolved parameters.
      def resolve_parameters(params) # rubocop:disable Metrics/MethodLength
        validate_parameters(**params)

        entity_class   = entity_class_from(**params)
        class_name     = entity_class_name(entity_class)
        name           = relation_name_from(**params, class_name:)
        plural_name    = plural_name_from(**params, name:)
        qualified_name = qualified_name_from(**params, class_name:)
        singular_name  = singular_name_from(**params, name:)

        {
          entity_class:,
          name:,
          plural_name:,
          qualified_name:,
          singular_name:
        }
      end

      private

      def classify(raw)
        raw
          .then { |str| tools.string_tools.singularize(str).to_s }
          .split('/')
          .map { |str| tools.string_tools.camelize(str) }
          .join('::')
      end

      def entity_class_from(**params)
        if has_key?(params, :entity_class)
          entity_class = params[:entity_class]

          return entity_class.is_a?(Class) ? entity_class : entity_class.to_s
        end

        if has_key?(params, :qualified_name)
          return classify(params[:qualified_name])
        end

        classify(params[:name])
      end

      def entity_class_name(entity_class, scoped: true)
        (entity_class.is_a?(Class) ? entity_class.name : entity_class)
          .split('::')
          .map { |str| tools.string_tools.underscore(str) }
          .then { |ary| scoped ? ary.join('/') : ary.last }
      end

      def has_key?(params, key) # rubocop:disable Naming/PredicateName
        return false unless params.key?(key)

        !params[key].nil?
      end

      def plural_name_from(name:, **parameters)
        if parameters.key?(:plural_name) && !parameters[:plural_name].nil?
          return validate_parameter(
            parameters[:plural_name],
            as: 'plural name'
          )
        end

        tools.string_tools.pluralize(name)
      end

      def qualified_name_from(class_name:, **params)
        return params[:qualified_name].to_s if has_key?(params, :qualified_name)

        tools.string_tools.pluralize(class_name)
      end

      def relation_name_from(class_name:, **params)
        return params[:name].to_s if has_key?(params, :name)

        tools.string_tools.pluralize(class_name.split('/').last)
      end

      def singular_name_from(name:, **parameters)
        if parameters.key?(:singular_name) && !parameters[:singular_name].nil?
          return validate_parameter(
            parameters[:singular_name],
            as: 'singular name'
          )
        end

        tools.string_tools.singularize(name)
      end

      def tools
        SleepingKingStudios::Tools::Toolbelt.instance
      end

      def validate_entity_class(value)
        return if value.is_a?(Class)

        if value.nil? || value.is_a?(String) || value.is_a?(Symbol)
          tools.assertions.validate_name(value, as: 'entity class')

          return
        end

        raise ArgumentError,
          'entity class is not a Class, a String or a Symbol'
      end

      def validate_parameter(value, as:)
        tools.assertions.validate_name(value, as:)

        value.to_s
      end

      def validate_parameter_keys(params)
        return if PARAMETER_KEYS.any? { |key| has_key?(params, key) }

        raise ArgumentError, "name or entity class can't be blank"
      end

      def validate_parameters(**params) # rubocop:disable Metrics/MethodLength
        validate_parameter_keys(params)

        if has_key?(params, :entity_class)
          validate_entity_class(params[:entity_class])
        end

        validate_parameter(params[:name], as: 'name') if has_key?(params, :name)

        if has_key?(params, :plural_name)
          validate_parameter(params[:plural_name], as: 'plural name')
        end

        if has_key?(params, :qualified_name)
          validate_parameter(params[:qualified_name], as: 'qualified name')
        end

        if has_key?(params, :singular_name) # rubocop:disable Style/GuardClause
          validate_parameter(params[:singular_name], as: 'singular name')
        end
      end
    end

    # @return [String] the name of the relation.
    attr_reader :name

    # @return [String] the pluralized name of the relation.
    attr_reader :plural_name

    # @return [String] a scoped name for the relation.
    attr_reader :qualified_name

    # @return [String] the name of an entity in the relation.
    attr_reader :singular_name

    # @return [Class] the class of entity represented by the relation.
    def entity_class
      return @entity_class if @entity_class.is_a?(Class)

      @entity_class = Object.const_get(@entity_class)
    end

    # (see Cuprum::Collections::Relations::Parameters.resolve_parameters)
    def resolve_parameters(parameters)
      Parameters.resolve_parameters(parameters)
    end
  end
end
