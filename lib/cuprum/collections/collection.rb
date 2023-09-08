# frozen_string_literal: true

require 'cuprum/command_factory'

require 'cuprum/collections'
require 'cuprum/collections/relation'

module Cuprum::Collections
  # Provides a base implementation for collections.
  class Collection < Cuprum::CommandFactory
    include Cuprum::Collections::Relation::Parameters
    include Cuprum::Collections::Relation::PrimaryKeys
    include Cuprum::Collections::Relation::Disambiguation

    # Error raised when trying to call an abstract collection method.
    class AbstractCollectionError < StandardError; end

    IGNORED_PARAMETERS = %i[
      collection_name
      entity_class
      member_name
      name
      qualified_name
      singular_name
    ].freeze
    private_constant :IGNORED_PARAMETERS

    # @overload initialize(entity_class: nil, name: nil, qualified_name: nil, singular_name: nil, **options)
    #   @param entity_class [Class, String] the class of entity represented by
    #     the relation.
    #   @param name [String] the name of the relation. Aliased as
    #     :collection_name.
    #   @param qualified_name [String] a scoped name for the relation.
    #   @param singular_name [String] the name of an entity in the relation.
    #     Aliased as :member_name.
    #   @param options [Hash] additional options for the relation.
    #
    #   @option options primary_key_name [String] the name of the primary key
    #     attribute. Defaults to 'id'.
    #   @option primary_key_type [Class, Stannum::Constraint] the type of
    #     the primary key attribute. Defaults to Integer.
    def initialize(**parameters) # rubocop:disable Metrics/MethodLength
      super()

      relation_params = resolve_parameters(
        parameters,
        name:          :collection_name,
        singular_name: :member_name
      )
      @entity_class   = relation_params[:entity_class]
      @name           = relation_params[:name]
      @qualified_name = relation_params[:qualified_name]
      @singular_name  = relation_params[:singular_name]

      @options = ignore_parameters(**parameters)
    end

    alias collection_name name

    alias member_name singular_name

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
      comparable_options >= expected
    end

    # A new Query instance, used for querying against the collection data.
    #
    # @return [Object] the query.
    def query
      raise AbstractCollectionError,
        "#{self.class.name} is an abstract class. Define a repository " \
        'subclass and implement the #query method.'
    end

    protected

    def comparable_options
      command_options.merge(
        name:          name,
        singular_name: singular_name
      )
    end

    private

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
