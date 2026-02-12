# frozen_string_literal: true

require 'bronze'
require 'bronze/relations/options'
require 'bronze/relations/parameters'

module Bronze
  # Abstract class representing a group or view of entities.
  class Relation
    include Bronze::Relations::Options
    include Bronze::Relations::Parameters

    # @!method initialize(entity_class: nil, name: nil, qualified_name: nil, singular_name: nil, **options)
    #   @param entity_class [Class, String] the class of entity represented by
    #     the relation.
    #   @param name [String] the name of the relation.
    #   @param qualified_name [String] a scoped name for the relation.
    #   @param singular_name [String] the name of an entity in the relation.
    #   @param options [Hash] additional options for the relation.
  end
end
