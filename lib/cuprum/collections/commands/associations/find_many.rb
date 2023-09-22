# frozen_string_literal: true

require 'cuprum/collections/commands/associations'

module Cuprum::Collections::Commands::Associations
  # Command for querying entities by association.
  class FindMany < Cuprum::Command
    # @param association [Cuprum::Collections::Association] the association to
    #   query.
    # @param repository [Cuprum::Collections::Repository] the repository to
    #   query from.
    # @param resource [Cuprum::Collections::Resource] the base resource for the
    #   association.
    def initialize(association:, repository:, resource:)
      super()

      @association = association
      @repository  = repository
      @resource    = resource
    end

    # @return [Cuprum::Collections::Association] the association to query.
    attr_reader :association

    # @return [Cuprum::Collections::Repository] the repository to query from.
    attr_reader :repository

    # @return [Cuprum::Collections::Resource] the base resource for the
    #   association.
    attr_reader :resource

    private

    def collection
      repository.find_or_create(
        name:           tools.string_tools.pluralize(association.name),
        qualified_name: association.qualified_name
      )
    end

    def perform_query(association:, expected_keys:)
      query        = association.build_keys_query(*expected_keys)
      find_command = collection.find_matching

      find_command.call(&query)
    end

    def process(*entities_or_keys)
      association   = @association.with_inverse(resource)
      expected_keys =
        association.map_entities_to_keys(*entities_or_keys, strict: false)

      return singular? ? nil : [] if expected_keys.empty?

      values = step do
        perform_query(association: association, expected_keys: expected_keys)
      end

      singular? ? values.first : values.to_a
    end

    def singular?
      association.singular? && resource.singular?
    end

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
    end
  end
end
