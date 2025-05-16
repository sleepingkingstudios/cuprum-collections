# frozen_string_literal: true

require 'cuprum/collections/commands/associations'

module Cuprum::Collections::Commands::Associations
  # Command for querying entities by association.
  class FindMany < Cuprum::Command
    PERMITTED_KEYWORDS = Set.new(%i[entities entity key keys]).freeze
    private_constant :PERMITTED_KEYWORDS

    # @!method call(**params)
    #   @overload call(key:)
    #     Finds the association values for the given key.
    #
    #     @param key [Object] the primary or foreign key for querying the
    #       association.
    #
    #     @return [Object, nil] the association value or nil, if the association
    #       is singular.
    #     @return [Array<Object>] the association values, if the association is
    #       plural.
    #
    #   @overload call(keys:)
    #     Finds the association values for the given Array of keys.
    #     @return [Array<Object>] the association values.
    #
    #     @param keys [Array<Object>] the primary or foreign keys for querying
    #       the association.
    #
    #     @return [Array<Object>] the association values.
    #
    #   @overload call(entity:)
    #     Finds the association values for the given entity.
    #
    #     @param entity [Object] the base entity for querying the association.
    #
    #     @return [Object, nil] the association value or nil, if the association
    #       is singular.
    #     @return [Array<Object>] the association values, if the association is
    #       plural.
    #
    #   @overload call(entities:)
    #     Finds the association values for the given Array of entities.
    #
    #     @param entity [Array<Object>] the base entities for querying the
    #       association.
    #
    #     @return [Array<Object>] the association values.

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
        qualified_name: association.qualified_name
      )
    end

    def extract_keys(association, hsh)
      return hsh[:key]  if hsh.key?(:key)
      return hsh[:keys] if hsh.key?(:keys)

      values = hsh.fetch(:entity) { hsh[:entities] }

      if values.is_a?(Array)
        association.map_entities_to_keys(*values)
      else
        association.map_entities_to_keys(values).first
      end
    end

    def handle_ambiguous_keys(hsh)
      return if hsh.keys.size == 1

      raise ArgumentError,
        "ambiguous keywords #{hsh.each_key.map(&:inspect).join(', ')} " \
        '- must provide exactly one parameter'
    end

    def handle_extra_keys(hsh)
      return if hsh.keys.all? { |key| PERMITTED_KEYWORDS.include?(key) }

      extra_keys = hsh.keys - PERMITTED_KEYWORDS.to_a

      raise ArgumentError,
        "invalid keywords #{extra_keys.map(&:inspect).join(', ')}"
    end

    def handle_missing_keys(hsh)
      return unless hsh.empty?

      raise ArgumentError, 'missing keyword :entity, :entities, :key, or :keys'
    end

    def perform_query(association:, expected_keys:, **)
      query        = association.build_keys_query(*expected_keys)
      find_command = collection.find_matching

      find_command.call(&query)
    end

    def process(**params) # rubocop:disable Metrics/MethodLength
      association           = @association.with_inverse(resource)
      expected_keys, plural = resolve_keys(association, **params)
      plural              ||= association.plural?

      return plural ? [] : nil if expected_keys.empty?

      values = step do
        perform_query(
          association:,
          expected_keys:,
          plural:
        )
      end

      plural ? values.to_a : values.first
    end

    def resolve_keys(association, **params)
      handle_missing_keys(params)
      handle_extra_keys(params)
      handle_ambiguous_keys(params)

      keys   = extract_keys(association, params)
      plural = keys.is_a?(Array)
      keys   = [keys] unless plural
      keys   = keys.compact.uniq

      [keys, plural]
    end
  end
end
