# frozen_string_literal: true

require 'cuprum/collections'
require 'cuprum/collections/resource'

module Cuprum::Collections
  # Class representing an association between resources.
  class Association < Resource # rubocop:disable Metrics/ClassLength
    # @overload initialize(entity_class: nil, name: nil, qualified_name: nil, singular_name: nil, **options)
    #   @param entity_class [Class, String] the class of entity represented by
    #     the resource.
    #   @param inverse [Cuprum::Collections::Resource] the inverse association,
    #     if any.
    #   @param name [String] the name of the resource.
    #   @param qualified_name [String] a scoped name for the resource.
    #   @param singular_name [String] the name of an entity in the resource.
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

    # @return [Cuprum::Collections::Resource] the inverse association, if any.
    attr_reader :inverse

    # @return [Class] the class of entity represented by the resource.
    def association_class
      tools.core_tools.deprecate '#association_class method',
        message: 'Use #entity_class instead'

      entity_class
    end

    # @return [String] the name of the resource.
    def association_name
      tools.core_tools.deprecate '#association_name method',
        message: 'Use #name instead'

      name
    end

    # Generates a query for finding matching items.
    #
    # @param entities [Array] the entities to query for.
    # @param allow_nil [Boolean] if true, allows for nil keys. Defaults to
    #   false.
    # @param deduplicate [Boolean] if true, removes duplicate keys before
    #   generating the query. Defaults to true.
    #
    # @return [Proc] the generated query.
    def build_entities_query(*entities, allow_nil: false, deduplicate: true)
      keys =
        map_entities_to_keys(
          *entities,
          allow_nil:   allow_nil,
          deduplicate: deduplicate,
          strict:      true
        )

      build_keys_query(*keys, allow_nil: allow_nil, deduplicate: false)
    end

    # Generates a query for finding matching items by key.
    #
    # @param keys [Array] the primary or foreign keys to query for.
    # @param allow_nil [Boolean] if true, allows for nil keys. Defaults to
    #   false.
    # @param deduplicate [Boolean] if true, removes duplicate keys before
    #   generating the query. Defaults to true.
    #
    # @return [Proc] the generated query.
    def build_keys_query(*keys, allow_nil: false, deduplicate: true)
      keys     = keys.compact unless allow_nil
      keys     = keys.uniq    if deduplicate
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

    # @return [String] the name of the inverse key.
    def inverse_key_name
      return foreign_key_name if primary_key_query?

      primary_key_name
    end

    # @return [String] the name of the inverse association, if any.
    def inverse_name
      @inverse_name ||=
        options
          .fetch(:inverse_name) { default_inverse_name }
          &.to_s
    end

    # Maps a list of entities to keys for performing a query.
    #
    # @param entities [Array] the entities to query for.
    # @param allow_nil [Boolean] if true, allows for nil keys. Defaults to
    #   false.
    # @param deduplicate [Boolean] if true, removes duplicate keys before
    #   generating the query. Defaults to true.
    # @param strict [Boolean] if true, raises an exception if given an Array of
    #   keys instead of entities.
    #
    # @return [Array] the primary or foreign keys to query for.
    def map_entities_to_keys(
      *entities,
      allow_nil:   false,
      deduplicate: true,
      strict:      true
    )
      entities
        .compact
        .map { |entity| map_entity_to_key(entity, strict: strict) }
        .then { |keys| allow_nil ? keys : keys.compact }
        .then { |keys| deduplicate ? keys.uniq : keys }
    end

    # @return [Boolean] true if the association queries by primary key, e.g. a
    #   :belongs_to association; false if the association queries by foreign
    #   key, e.g. a :has_one or :has_many association.
    def primary_key_query?
      false
    end

    # @return [String] the name of the key used to perform the query.
    def query_key_name
      return primary_key_name if primary_key_query?

      if foreign_key_name.nil? || foreign_key_name.empty?
        raise ArgumentError, "foreign key name can't be blank"
      end

      foreign_key_name
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
      primary_key_query? ? foreign_key_name : primary_key_name
    end

    def indexed?(value)
      return false if value.is_a?(Integer)

      return false if value.is_a?(String)

      value.respond_to?(:[])
    end

    def map_entity_to_key(value, strict: false)
      key = entity_key_name

      return value[key] if indexed?(value)

      return value.send(key) if value.respond_to?(key)

      return value if !strict && value.is_a?(primary_key_type)

      raise ArgumentError,
        "undefined method :[] or :#{key} for #{value.inspect}"
    end

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
    end
  end
end
