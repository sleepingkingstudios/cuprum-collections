# frozen_string_literal: true

require 'cuprum/command_factory'

require 'cuprum/collections'
require 'cuprum/collections/relation'
require 'cuprum/collections/scopes/null_scope'

module Cuprum::Collections
  # Provides a base implementation for collections.
  class Collection < Cuprum::CommandFactory
    include Cuprum::Collections::Relation::Parameters
    include Cuprum::Collections::Relation::PrimaryKeys

    # Error raised when trying to call an abstract collection method.
    class AbstractCollectionError < StandardError; end

    IGNORED_PARAMETERS = %i[
      entity_class
      name
      query
      qualified_name
      singular_name
    ].freeze
    private_constant :IGNORED_PARAMETERS

    # @overload initialize(entity_class: nil, name: nil, qualified_name: nil, singular_name: nil, **options)
    #   @param entity_class [Class, String] the class of entity represented by
    #     the relation.
    #   @param name [String] the name of the relation.
    #   @param qualified_name [String] a scoped name for the relation.
    #   @param singular_name [String] the name of an entity in the relation.
    #   @param options [Hash] additional options for the relation.
    #
    #   @option options primary_key_name [String] the name of the primary key
    #     attribute. Defaults to 'id'.
    #   @option primary_key_type [Class, Stannum::Constraint] the type of
    #     the primary key attribute. Defaults to Integer.
    def initialize(**parameters) # rubocop:disable Metrics/MethodLength
      super()

      relation_params = resolve_parameters(parameters)
      @entity_class   = relation_params[:entity_class]
      @name           = relation_params[:name]
      @plural_name    = relation_params[:plural_name]
      @qualified_name = relation_params[:qualified_name]
      @singular_name  = relation_params[:singular_name]

      @scope   =
        if parameters.key?(:scope)
          default_scope.and(parameters[:scope])
        else
          default_scope
        end
      @options = ignore_parameters(**parameters)
    end

    # @return [Hash<Symbol>] additional options for the collection.
    attr_reader :options

    # @param other [Object] The object to compare.
    #
    # @return [true, false] true if the other object is a collection with the
    #   same options, otherwise false.
    def ==(other)
      return false unless self.class == other.class

      comparable_options == other.comparable_options
    end

    # @return [Integer] the count of items in the collection.
    def count
      query.count
    end
    alias size count

    # Checks if the collection matches the expected options.
    #
    # @param expected [Hash] the options to compare.
    #
    # @return [Boolean] true if all of the expected options match, otherwise
    #   false.
    def matches?(**expected)
      if expected[:entity_class].is_a?(String)
        expected = expected.merge(
          entity_class: Object.const_get(expected[:entity_class])
        )
      end

      comparable_options >= expected
    end

    # A new Query instance, used for querying against the collection data.
    #
    # @return [Object] the query.
    def query
      raise AbstractCollectionError,
        "#{self.class.name} is an abstract class. Define a collection " \
        'subclass and implement the #query method.'
    end

    # @return [Cuprum::Collections::Scopes::Base] the configured scope for the
    #   collection.
    def scope
      @scope ||= default_scope
    end

    # Returns a copy of the collection that merges the given scope.
    def with_scope(other_scope)
      dup.tap { |copy| copy.scope = scope.and(other_scope) }
    end

    protected

    attr_writer :scope

    def comparable_options
      command_options.merge(
        name:           name,
        qualified_name: qualified_name,
        scope:          scope,
        singular_name:  singular_name
      )
    end

    private

    def command_options
      @command_options ||= {
        collection_name:  name,
        entity_class:     entity_class,
        member_name:      singular_name,
        primary_key_name: primary_key_name,
        primary_key_type: primary_key_type,
        **options
      }
    end

    def default_scope
      Cuprum::Collections::Scopes::NullScope.new
    end

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
