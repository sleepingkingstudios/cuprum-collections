# frozen_string_literal: true

require 'stannum/parameter_validation'

require 'cuprum/collections'
require 'cuprum/collections/errors/invalid_parameters'

module Cuprum::Collections
  # Abstract base class for commands implementing collection actions.
  class CollectionCommand < Cuprum::Command
    extend  Stannum::ParameterValidation
    include Stannum::ParameterValidation

    # @param collection [Cuprum::Collections::Collection] the collection to
    #   which the command belongs.
    def initialize(collection:)
      super()

      @collection = collection
    end

    # @return [Cuprum::Collections::Collection] the collection to which the
    #   command belongs.
    attr_reader :collection

    # @return [String] the name of the relation.
    def name
      @name ||= collection.name
    end
    alias collection_name name

    # @return [String] the name of the primary key attribute. Defaults to 'id'.
    def primary_key_name
      @primary_key_name ||= collection.primary_key_name
    end

    # @return [Class, Stannum::Constraint] the type of the primary key
    #   attribute. Defaults to Integer.
    def primary_key_type
      @primary_key_type ||= collection.primary_key_type
    end

    # A new Query instance, used for querying against the collection data.
    #
    # @return [Object] the query.
    def query
      collection.query
    end

    # @returnb [String] the name of an entity in the collection.
    def singular_name
      @singular_name ||= collection.singular_name
    end
    alias member_name singular_name

    private

    def handle_invalid_parameters(errors:, method_name:)
      return super unless method_name == :call

      error = Cuprum::Collections::Errors::InvalidParameters.new(
        command: self,
        errors:
      )
      failure(error)
    end
  end
end
