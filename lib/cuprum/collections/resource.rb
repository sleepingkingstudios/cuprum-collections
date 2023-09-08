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
    #     the resource. Aliased as :resource_class.
    #   @param name [String] the name of the resource.
    #   @param qualified_name [String] a scoped name for the resource.
    #   @param singular_name [String] the name of an entity in the resource.
    #     Aliased as :singular_resource_name.
    #   @param options [Hash] additional options for the resource.
    #
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

    alias resource_class entity_class
    alias resource_name name
    alias singular_resource_name singular_name
  end
end
