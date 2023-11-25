# frozen_string_literal: true

require 'cuprum/collections'
require 'cuprum/collections/relation'

module Cuprum::Collections
  # Class representing a singular or plural resource of entities.
  class Resource < Cuprum::Collections::Relation
    include Cuprum::Collections::Relation::Cardinality
    include Cuprum::Collections::Relation::Disambiguation
    include Cuprum::Collections::Relation::PrimaryKeys

    # @overload initialize(entity_class: nil, name: nil, qualified_name: nil, singular_name: nil, **options)
    #   @param entity_class [Class, String] the class of entity represented by
    #     the resource.
    #   @param name [String] the name of the resource. Aliased as
    #     :resource_name.
    #   @param qualified_name [String] a scoped name for the resource.
    #   @param singular_name [String] the name of an entity in the resource.
    #   @param options [Hash] additional options for the resource.
    #
    #   @option options plural [Boolean] if true, the resource represents a
    #     plural resource. Defaults to true. Can also be specified as :singular.
    #   @option options primary_key_name [String] the name of the primary key
    #     attribute. Defaults to 'id'.
    #   @option primary_key_type [Class, Stannum::Constraint] the type of
    #     the primary key attribute. Defaults to Integer.
    def initialize(**params)
      params  = disambiguate_keyword(params, :entity_class, :resource_class)
      params  = disambiguate_keyword(params, :name, :resource_name)
      params  = disambiguate_keyword(
        params,
        :singular_name,
        :singular_resource_name
      )
      @plural = resolve_plurality(**params)

      super(**params)
    end

    # @return [Class] the class of entity represented by the resource.
    def resource_class
      tools.core_tools.deprecate '#resource_class method',
        message: 'Use #entity_class instead'

      entity_class
    end

    # @return [String] the name of the resource.
    def resource_name
      tools.core_tools.deprecate '#resource_name method',
        message: 'Use #name instead'

      name
    end

    # @return[String] the name of an entity in the resource.
    def singular_resource_name
      tools.core_tools.deprecate '#singular_resource_name method',
        message: 'Use #singular_name instead'

      singular_name
    end
  end
end
