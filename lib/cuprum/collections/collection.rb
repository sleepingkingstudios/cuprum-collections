# frozen_string_literal: true

require 'cuprum/command_factory'

require 'cuprum/collections'

module Cuprum::Collections
  # Provides a base implementation for collections.
  class Collection < Cuprum::CommandFactory
    # Error raised when trying to call an abstract collection method.
    class AbstractCollectionError < StandardError; end

    # @param collection_name [String, Symbol] the name of the collection.
    # @param entity_class [Class, String] the class of entity represented in the
    #   collection.
    # @param options [Hash<Symbol>] additional options for the collection.
    #
    # @option options member_name [String] the name of a collection entity.
    # @option options primary_key_name [String] the name of the primary key
    #   attribute. Defaults to 'id'.
    # @option options primary_key_type [Class, Stannum::Constraint] the type of
    #   the primary key attribute. Defaults to Integer.
    # @option options qualified_name [String] the qualified name of the
    #   collection, which should be unique. Defaults to the collection name.
    def initialize(collection_name: nil, entity_class: nil, **options)
      super()

      @collection_name = resolve_collection_name(
        collection_name: collection_name,
        entity_class:    entity_class,
        **options
      )
      @options      = options
      @entity_class = resolve_entity_class(entity_class: entity_class)
    end

    # @return [String] the name of the collection.
    attr_reader :collection_name

    # @return [Class] the class of entity represented in the collection.
    attr_reader :entity_class

    # @return [Hash<Symbol>] additional options for the collection.
    attr_reader :options

    # @param other [Object] The object to compare.
    #
    # @return [true, false] true if the other object is a collection with the
    #   same options, otherwise false.
    def ==(other)
      return false unless self.class == other.class

      command_options == other.command_options
    end

    # @return [Integer] the count of items in the collection.
    def count
      query.count
    end
    alias size count

    # @return [String] the name of a collection entity.
    def member_name
      @member_name ||= options.fetch(
        :member_name,
        tools.string_tools.singularize(collection_name.to_s)
      ).to_s
    end

    # @return [Symbol] the name of the primary key attribute. Defaults to 'id'.
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

    # A new Query instance, used for querying against the collection data.
    #
    # @return [Object] the query.
    def query
      raise AbstractCollectionError,
        "#{self.class.name} is an abstract class. Define a repository " \
        'subclass and implement the #query method.'
    end

    # @return [String] the qualified name of the collection, which should be
    #   unique.
    def qualified_name
      @qualified_name ||= options.fetch(:qualified_name, collection_name).to_s
    end

    protected

    def command_options
      @command_options ||= {
        collection_name:  collection_name,
        entity_class:     entity_class,
        member_name:      member_name,
        primary_key_name: primary_key_name,
        primary_key_type: primary_key_type,
        **options
      }
    end

    private

    def default_entity_class
      qualified_name
        .split('/')
        .then { |ary| [*ary[0...-1], tools.string_tools.singularize(ary[-1])] }
        .map { |str| tools.string_tools.camelize(str) }
        .join('::')
    end

    def entity_class_name_for(entity_class)
      if entity_class.is_a?(Class)
        entity_class.name
      else
        tools.assertions.validate_name(entity_class, as: 'entity class')

        entity_class
      end
    end

    def extract_collection_name(entity_class:, **options)
      entity_class_name = entity_class_name_for(entity_class)
      segments          = entity_class_name
        .split('::')
        .map { |str| tools.string_tools.underscore(str) }
        .then { |ary| [*ary[0...-1], tools.string_tools.pluralize(ary[-1])] }

      @qualified_name = segments.join('/') unless options.key?(:qualified_name)

      segments.last
    end

    def resolve_collection_name(collection_name:, entity_class:, **options)
      if collection_name
        tools.assertions.validate_name(collection_name, as: 'collection name')

        return collection_name.to_s
      end

      if entity_class
        return extract_collection_name(entity_class: entity_class, **options)
      end

      tools.assertions.validate_name(collection_name, as: 'collection name')
    end

    def resolve_entity_class(entity_class:)
      value = entity_class || default_entity_class

      value.is_a?(String) ? Object.const_get(value) : value
    end

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
    end
  end
end
