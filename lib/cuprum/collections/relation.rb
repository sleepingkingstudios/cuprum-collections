# frozen_string_literal: true

require 'set'

require 'cuprum/collections'

module Cuprum::Collections
  # Abstract class representing a group or view of entities.
  class Relation
    # Methods for resolving a relations's naming and entity class from options.
    module Parameters # rubocop:disable Metrics/ModuleLength
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
          singular_name  = singular_name_from(**params, name: name)
          qualified_name = qualified_name_from(**params, class_name: class_name)

          {
            entity_class:   entity_class,
            singular_name:  singular_name,
            name:           name,
            qualified_name: qualified_name
          }
        end

        private

        def classify(raw)
          raw
            .then { |str| tools.string_tools.singularize(str) }
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
              as: 'member name'
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

        def validate_parameters(**params) # rubocop:disable Metrics/MethodLength
          unless has_key?(params, :entity_class) || has_key?(params, :name)
            raise ArgumentError, "name or entity class can't be blank"
          end

          if has_key?(params, :entity_class)
            validate_entity_class(params[:entity_class])
          end

          if has_key?(params, :singular_name)
            validate_parameter(params[:singular_name], as: 'member name')
          end

          if has_key?(params, :name)
            validate_parameter(params[:name], as: 'name')
          end

          if has_key?(params, :qualified_name) # rubocop:disable Style/GuardClause
            validate_parameter(params[:qualified_name], as: 'qualified name')
          end
        end
      end

      # @return [String] the name of an entity in the relation.
      attr_reader :singular_name

      # @return [String] the name of the relation.
      attr_reader :name

      # @return [String] a scoped name for the relation.
      attr_reader :qualified_name

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

    IGNORED_PARAMETERS = %i[
      entity_class
      name
      qualified_name
      singular_name
    ].freeze
    private_constant :IGNORED_PARAMETERS

    include Cuprum::Collections::Relation::Parameters

    # @overload initialize(entity_class: nil, singular_name: nil, name: nil, qualified_name: nil, **options)
    #   @param entity_class [Class, String] the class of entity represented by
    #     the relation.
    #   @param singular_name [String] the name of an entity in the relation.
    #   @param name [String] the name of the relation.
    #   @param qualified_name [String] a scoped name for the relation.
    #   @param options [Hash] additional options for the relation.
    def initialize(**parameters)
      relation_params = resolve_parameters(parameters)

      @entity_class   = relation_params[:entity_class]
      @name           = relation_params[:name]
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
  end
end
