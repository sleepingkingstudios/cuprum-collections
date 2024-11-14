# frozen_string_literal: true

require 'set'

require 'cuprum/collections'
require 'cuprum/collections/relations/parameters'

module Cuprum::Collections
  # Abstract class representing a group or view of entities.
  class Relation
    include Cuprum::Collections::Relations::Parameters

    IGNORED_PARAMETERS = %i[
      entity_class
      name
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
    def initialize(**parameters)
      relation_params = resolve_parameters(parameters)

      @entity_class   = relation_params[:entity_class]
      @name           = relation_params[:name]
      @plural_name    = relation_params[:plural_name]
      @qualified_name = relation_params[:qualified_name]
      @singular_name  = relation_params[:singular_name]

      @options = ignore_parameters(**parameters)
    end

    # @return [Hash] additional options for the relation.
    attr_reader :options

    private

    def ignore_parameters(**parameters)
      parameters.except(*ignored_parameters)
    end

    def ignored_parameters
      @ignored_parameters ||= Set.new(IGNORED_PARAMETERS)
    end
  end
end
