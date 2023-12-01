# frozen_string_literal: true

require 'set'

require 'cuprum/collections'

module Cuprum::Collections
  # Abstract class representing a group or view of entities.
  class Relation
    # Methods for resolving a singular or plural relation.
    module Cardinality
      # @return [Boolean] true if the relation is plural; otherwise false.
      def plural?
        @plural
      end

      # @return [Boolean] true if the relation is singular; otherwise false.
      def singular?
        !@plural
      end

      private

      def resolve_plurality(**params) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        if params.key?(:plural) && !params[:plural].nil?
          if params.key?(:singular) && !params[:singular].nil?
            message =
              'ambiguous cardinality: initialized with parameters ' \
              "plural: #{params[:plural].inspect} and singular: " \
              "#{params[:singular].inspect}"

            raise ArgumentError, message
          end

          validate_cardinality(params[:plural], as: 'plural')

          return params[:plural]
        end

        if params.key?(:singular) && !params[:singular].nil?
          validate_cardinality(params[:singular], as: 'singular')

          return !params[:singular]
        end

        true
      end

      def validate_cardinality(value, as:)
        return if value == true || value == false # rubocop:disable Style/MultipleComparison

        raise ArgumentError, "#{as} must be true or false"
      end
    end

    # Methods for disambiguating parameters with multiple keywords.
    module Disambiguation
      class << self
        # Helper method for resolving an ambiguous keyword.
        #
        # @param params [Hash] the original method keywords.
        # @param key [Symbol] the original key to resolve.
        # @param alternatives [Symbol, Array<Symbol>] the additional keywords.
        #
        # @return [Hash] the disambiguated keywords.
        def disambiguate_keyword(params, key, *alternatives) # rubocop:disable Metrics/MethodLength
          params = params.dup
          values = keyword_values(params, key, *alternatives)

          return params if values.empty?

          if values.size == 1
            match, value = values.first

            unless match == key
              tools.core_tools.deprecate(
                "#{match.inspect} keyword",
                message: "Use #{key.inspect} instead"
              )
            end

            return params.merge(key => value)
          end

          raise ArgumentError, ambiguous_keywords_error(values)
        end

        # Helper method for resolving a Relation's required parameters.
        #
        # The returned Hash will define the :entity_class, :singular_name,
        # :name, and :qualified_name keys.
        #
        # @param params [Hash] the parameters to resolve.
        # @param ambiguous [Hash{Symbol => Symbol, Array<Symbol>}] ambiguous
        #   keywords to resolve. Each key-value pair is passed to
        #   .disambiguate_keyword before the parameters are resolved.
        #
        # @return [Hash] the resolved parameters.
        #
        # @see .disambiguate_keyword
        # @see Cuprum::Collections::Relation::Parameters.resolve_parameters
        def resolve_parameters(params, **ambiguous)
          params = ambiguous.reduce(params) do |hsh, (key, alternatives)|
            disambiguate_keyword(hsh, key, *alternatives)
          end

          Cuprum::Collections::Relation::Parameters.resolve_parameters(params)
        end

        private

        def ambiguous_keywords_error(values)
          expected, _ = values.first
          formatted   =
            values
              .map { |key, value| "#{key}: #{value.inspect}" }
              .join(', ')

          "ambiguous parameter #{expected}: initialized with parameters " \
            "#{formatted}"
        end

        def keyword_values(keywords, *keys)
          keys
            .map { |key| [key, keywords.delete(key)] }
            .reject { |_, value| value.nil? } # rubocop:disable Style/CollectionCompact
        end

        def tools
          SleepingKingStudios::Tools::Toolbelt.instance
        end
      end

      # (see Cuprum::Collections::Relation::Disambiguation.disambiguate_keyword)
      def disambiguate_keyword(params, key, *alternatives)
        Disambiguation.disambiguate_keyword(params, key, *alternatives)
      end

      # (see Cuprum::Collections::Relation::Disambiguation.resolve_parameters)
      def resolve_parameters(params, **ambiguous)
        Disambiguation.resolve_parameters(params, **ambiguous)
      end
    end

    # Methods for resolving a relations's naming and entity class from options.
    module Parameters # rubocop:disable Metrics/ModuleLength
      PARAMETER_KEYS = %i[entity_class name qualified_name].freeze
      private_constant :PARAMETER_KEYS

      class << self
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
          name           = relation_name_from(**params, class_name: class_name)
          plural_name    = plural_name_from(**params, name: name)
          qualified_name = qualified_name_from(**params, class_name: class_name)
          singular_name  = singular_name_from(**params, name: name)

          {
            entity_class:   entity_class,
            name:           name,
            plural_name:    plural_name,
            qualified_name: qualified_name,
            singular_name:  singular_name
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
          if has_key?(params, :qualified_name)
            return params[:qualified_name].to_s
          end

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
          tools.assertions.validate_name(value, as: as)

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

          if has_key?(params, :name)
            validate_parameter(params[:name], as: 'name')
          end

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

      # (see Cuprum::Collections::Relation::Parameters.resolve_parameters)
      def resolve_parameters(parameters)
        Parameters.resolve_parameters(parameters)
      end
    end

    # Methods for specifying a relation's primary key.
    module PrimaryKeys
      # @return [String] the name of the primary key attribute. Defaults to
      #   'id'.
      def primary_key_name
        @primary_key_name ||= options.fetch(:primary_key_name, 'id').to_s
      end

      # @return [Class, Stannum::Constraint] the type of the primary key
      #   attribute. Defaults to Integer.
      def primary_key_type
        @primary_key_type ||=
          options
            .fetch(:primary_key_type, Integer)
            .then { |obj| obj.is_a?(String) ? Object.const_get(obj) : obj }
      end
    end

    IGNORED_PARAMETERS = %i[
      entity_class
      name
      qualified_name
      singular_name
    ].freeze
    private_constant :IGNORED_PARAMETERS

    include Cuprum::Collections::Relation::Parameters

    # @overload initialize(entity_class: nil, name: nil, qualified_name: nil, singular_name: nil, **options)
    #   @param entity_class [Class, String] the class of entity represented by
    #     the relation.
    #   @param name [String] the name of the relation.
    #   @param qualified_name [String] a scoped name for the relation.
    #   @param singular_name [String] the name of an entity in the relation.
    #   @param options [Hash] additional options for the relation.
    def initialize(**parameters)
      relation_params = resolve_parameters(parameters)

      @entity_class   = relation_params[:entity_class]
      @name           = relation_params[:name]
      @plural_name    = relation_params[:plural_name]
      @qualified_name = relation_params[:qualified_name]
      @singular_name  = relation_params[:singular_name]

      @options = ignore_parameters(**parameters)
    end

    # @return [Hash] additional options for the relation.
    attr_reader :options

    private

    def ignore_parameters(**parameters)
      parameters
        .reject { |key, _| ignored_parameters.include?(key) }
        .to_h
    end

    def ignored_parameters
      @ignored_parameters ||= Set.new(IGNORED_PARAMETERS)
    end

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
    end
  end
end
