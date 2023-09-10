# frozen_string_literal: true

require 'cuprum/collections'
require 'cuprum/collections/resource'

module Cuprum::Collections
  # Class representing an association between resources.
  class Association < Resource
    # @overload initialize(entity_class: nil, name: nil, qualified_name: nil, singular_name: nil, **options)
    #   @param entity_class [Class, String] the class of entity represented by
    #     the resource. Aliased as :association_class, :resource_class.
    #   @param inverse [Cuprum::Collections::Resource] the inverse association,
    #     if any.
    #   @param name [String] the name of the resource. Aliased as
    #     :association_name, :resource_name.
    #   @param qualified_name [String] a scoped name for the resource.
    #   @param singular_name [String] the name of an entity in the resource.
    #     Aliased as :singular_resource_name.
    #   @param options [Hash] additional options for the resource.
    #
    #   @option options foreign_key_name [String] the name of the foreign key
    #     attribute.
    #   @option options inverse_class [Class, String] the class of the inverse
    #     association.
    #   @option options inverse_name [String, Symbol] the name of the inverse
    #     association.
    #   @option options plural [Boolean] if true, the resource represents a
    #     plural resource. Defaults to true. Can also be specified as :singular.
    #   @option options primary_key_name [String] the name of the primary key
    #     attribute. Defaults to 'id'.
    #   @option primary_key_type [Class, Stannum::Constraint] the type of
    #     the primary key attribute. Defaults to Integer.
    #   @option options singular_inverse_name [String, Symbol] the name of an
    #     entity in the inverse association.
    def initialize(**params)
      params = disambiguate_keyword(params, :entity_class, :association_class)
      params = disambiguate_keyword(params, :name, :association_name)

      @inverse = params.delete(:inverse)

      super(**params)
    end

    alias association_class entity_class
    alias association_name name

    # @return [Cuprum::Collections::Resource] the inverse association, if any.
    attr_reader :inverse

    # Generates a query for finding matching items.
    #
    # @param entities [Array] the entities to query for.
    #
    # @return [Proc] the generated query.
    def build_entities_query(*entities, allow_nil: false)
      keys = entities.compact.map { |entity| map_entity_to_key(entity) }

      build_keys_query(*keys, allow_nil: allow_nil)
    end

    # Generates a query for finding matching items by key.
    #
    # @param keys [Array] the foreign keys to query for.
    # @param allow_nil [Boolean] if true, allows for nil keys. Defaults to
    #   false.
    #
    # @return [Proc] the generated query.
    def build_keys_query(*keys, allow_nil: false)
      keys     = keys.compact unless allow_nil
      keys     = keys.uniq
      hash_key = query_key_name

      if keys.empty?
        -> { {} }
      elsif keys.size == 1
        -> { { hash_key => keys.first } }
      else
        -> { { hash_key => one_of(keys) } }
      end
    end

    # @return [String] the name of the foreign key attribute.
    def foreign_key_name
      @foreign_key_name ||=
        options
          .fetch(:foreign_key_name) { default_foreign_key_name }
          &.to_s
    end

    # @return [Class] the class of the inverse association, if any.
    def inverse_class
      @inverse_class ||=
        options
          .fetch(:inverse_class) { inverse&.entity_class }
          .then do |value|
            value.is_a?(String) ? Object.const_get(value) : value
          end
    end

    # @return [String] the name of the inverse association, if any.
    def inverse_name
      @inverse_name ||=
        options
          .fetch(:inverse_name) { default_inverse_name }
          &.to_s
    end

    # @return [String] the name of an entity in the inverse association.
    def singular_inverse_name
      @singular_inverse_name ||=
        options
          .fetch(:singular_inverse_name) { default_singular_inverse_name }
          &.to_s
    end

    # Creates a copy of the association with the specified inverse association.
    #
    # @param inverse [Cuprum::Collections::Resource] the inverse association.
    #
    # @return [Cuprum::Collections::Association] the copied association.
    def with_inverse(inverse)
      dup.assign_inverse(inverse)
    end

    protected

    def assign_inverse(inverse)
      @inverse               = inverse
      @inverse_class         = nil
      @inverse_name          = nil
      @foreign_key_name      = nil
      @singular_inverse_name = nil

      self
    end

    private

    def default_foreign_key_name
      singular_inverse_name&.then { |str| "#{str}_id" }
    end

    def default_inverse_name
      inverse&.name
    end

    def default_singular_inverse_name
      return inverse.singular_name if inverse

      return tools.string_tools.singularize(inverse_name) if inverse_name

      nil
    end

    def entity_key_name
      primary_key_name
    end

    def map_entity_to_key(entity)
      return entity[entity_key_name] if entity.respond_to?(:[])

      entity.send(entity_key_name)
    end

    def query_key_name
      if foreign_key_name.nil? || foreign_key_name.empty?
        raise ArgumentError, "foreign key name can't be blank"
      end

      foreign_key_name
    end

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
    end
  end
end
