# frozen_string_literal: true

require 'cuprum/collections'
require 'cuprum/collections/relation'
require 'cuprum/collections/relations/cardinality'
require 'cuprum/collections/relations/primary_keys'

module Cuprum::Collections
  # Class representing a singular or plural resource of entities.
  class Resource < Cuprum::Collections::Relation
    include Cuprum::Collections::Relations::Cardinality
    include Cuprum::Collections::Relations::PrimaryKeys

    # @overload initialize(entity_class: nil, name: nil, qualified_name: nil, singular_name: nil, **options)
    #   @param entity_class [Class, String] the class of entity represented by
    #     the resource.
    #   @param name [String] the name of the resource.
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
  end
end
