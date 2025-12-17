# frozen_string_literal: true

require 'cuprum/collections/relations'

module Cuprum::Collections::Relations
  # Methods for resolving a relations's naming and entity class from options.
  module Parameters # rubocop:disable Metrics/ModuleLength
    IGNORED_PARAMETERS = %i[
      entity_class
      name
      qualified_name
      singular_name
    ].freeze
    private_constant :IGNORED_PARAMETERS

    OPTIONAL_PARAMETER_KEYS = %i[plural_name singular_name].freeze
    private_constant :OPTIONAL_PARAMETER_KEYS

    REQUIRED_PARAMETER_KEYS = %i[entity_class name qualified_name].freeze
    private_constant :REQUIRED_PARAMETER_KEYS

    PARAMETER_KEYS = (OPTIONAL_PARAMETER_KEYS + REQUIRED_PARAMETER_KEYS).freeze
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
      def resolve_parameters(params)
        validate_parameters(**params)

        if has_key?(params, :entity_class)
          resolve_parameters_from_entity_class(**params)
        else
          resolve_parameters_from_name(**params)
        end
      end

      private

      def classify(raw)
        raw
          .then { |str| tools.string_tools.singularize(str).to_s }
          .split('/')
          .map { |str| tools.string_tools.camelize(str) }
          .join('::')
      end

      def has_key?(params, key) # rubocop:disable Naming/PredicatePrefix
        return false unless params.key?(key)

        !params[key].nil?
      end

      def resolve_entity_class(params)
        entity_class = classify(params[:qualified_name])

        params.update(entity_class:)
      end

      def resolve_entity_name(params)
        entity_class = params[:entity_class]
        entity_name  =
          (entity_class.is_a?(Class) ? entity_class.name : entity_class)
            .split('::')
            .map { |str| tools.string_tools.underscore(str) }
            .join('/')

        params.update(entity_name:)
      end

      def resolve_name(params)
        name =
          if has_key?(params, :name)
            params[:name].to_s
          elsif has_key?(params, :entity_name)
            tools.string_tools.pluralize(params[:entity_name].split('/').last)
          else
            params[:qualified_name].split('/').last
          end

        params.update(name:)
      end

      def resolve_parameters_from_entity_class(**params)
        params
          .slice(*PARAMETER_KEYS)
          .then { |hsh| resolve_entity_name(hsh) }
          .then { |hsh| resolve_qualified_name(hsh) }
          .then { |hsh| resolve_name(hsh) }
          .then { |hsh| resolve_plural_name(hsh) }
          .then { |hsh| resolve_singular_name(hsh) }
          .tap  { |hsh| hsh.delete(:entity_name) }
      end

      def resolve_parameters_from_name(**params)
        params
          .slice(*PARAMETER_KEYS)
          .then { |hsh| resolve_qualified_name(hsh) }
          .then { |hsh| resolve_name(hsh) }
          .then { |hsh| resolve_plural_name(hsh) }
          .then { |hsh| resolve_singular_name(hsh) }
          .then { |hsh| resolve_entity_class(hsh) }
      end

      def resolve_plural_name(params)
        plural_name =
          if has_key?(params, :plural_name)
            validate_parameter(
              params[:plural_name],
              as: 'plural name'
            )
          else
            tools.string_tools.pluralize(params[:name])
          end

        params.update(plural_name:)
      end

      def resolve_qualified_name(params)
        qualified_name =
          if has_key?(params, :qualified_name)
            params[:qualified_name].to_s
          elsif has_key?(params, :entity_name)
            tools.string_tools.pluralize(params[:entity_name])
          elsif has_key?(params, :name)
            tools.string_tools.pluralize(params[:name])
          end

        params.update(qualified_name:)
      end

      def resolve_singular_name(params)
        singular_name =
          if has_key?(params, :singular_name)
            validate_parameter(
              params[:singular_name],
              as: 'singular name'
            )
          else
            tools.string_tools.singularize(params[:name])
          end

        params.update(singular_name:)
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
        return if REQUIRED_PARAMETER_KEYS.any? { |key| has_key?(params, key) }

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

    # @overload initialize(entity_class: nil, name: nil, qualified_name: nil, singular_name: nil, **)
    #   @param entity_class [Class, String] the class of entity represented by
    #     the relation.
    #   @param name [String] the name of the relation.
    #   @param qualified_name [String] a scoped name for the relation.
    #   @param singular_name [String] the name of an entity in the relation.
    def initialize(**parameters)
      super(**parameters.except(*IGNORED_PARAMETERS))

      relation_params = resolve_parameters(parameters)

      @entity_class   = relation_params[:entity_class]
      @name           = relation_params[:name]
      @plural_name    = relation_params[:plural_name]
      @qualified_name = relation_params[:qualified_name]
      @singular_name  = relation_params[:singular_name]
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
