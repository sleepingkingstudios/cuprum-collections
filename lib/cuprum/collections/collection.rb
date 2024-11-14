# frozen_string_literal: true

require 'cuprum/command_factory'

require 'cuprum/collections'
require 'cuprum/collections/relation'
require 'cuprum/collections/relations/options'
require 'cuprum/collections/relations/parameters'
require 'cuprum/collections/relations/primary_keys'
require 'cuprum/collections/relations/scope'
require 'cuprum/collections/scopes/all_scope'

module Cuprum::Collections
  # Provides a base implementation for collections.
  class Collection < Cuprum::CommandFactory
    include Cuprum::Collections::Relations::Options
    include Cuprum::Collections::Relations::Parameters
    include Cuprum::Collections::Relations::PrimaryKeys
    include Cuprum::Collections::Relations::Scope

    # Error raised when trying to call an abstract collection method.
    class AbstractCollectionError < StandardError; end

    # @!method initialize(entity_class: nil, name: nil, qualified_name: nil, singular_name: nil, **options)
    #   @param entity_class [Class, String] the class of entity represented by
    #     the relation.
    #   @param name [String] the name of the relation.
    #   @param qualified_name [String] a scoped name for the relation.
    #   @param singular_name [String] the name of an entity in the relation.
    #   @param options [Hash] additional options for the relation.
    #
    #   @option options primary_key_name [String] the name of the primary key
    #     attribute. Defaults to 'id'.
    #   @option options primary_key_type [Class, Stannum::Constraint] the type
    #     of the primary key attribute. Defaults to Integer.
    #   @option options scope
    #     [Cuprum::Collections::Scopes::Base, Hash, Proc, nil] the configured
    #     scope for the relation.

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

    protected

    def comparable_options
      @comparable_options ||= {
        entity_class:,
        name:,
        primary_key_name:,
        primary_key_type:,
        qualified_name:,
        scope:,
        singular_name:,
        **options
      }
    end
  end
end
