# frozen_string_literal: true

require 'cuprum/collections/commands'
require 'cuprum/collections/errors/not_found'
require 'cuprum/collections/errors/not_unique'

module Cuprum::Collections::Commands
  # Command for finding a unique entity by a query or set of attributes.
  #
  # @example Finding An Entity By Attributes
  #   command =
  #     Cuprum::Collections::Commands::FindOneMatching
  #     .new(collection: books_collection)
  #
  #   # With an attributes Hash that matches one entity.
  #   result = command.call(attributes: { 'title' => 'Gideon the Ninth' })
  #   result.success?
  #   #=> true
  #   result.value
  #   #=> a Book with title 'Gideon the Ninth'
  #
  #   # With an attributes Hash that matches multiple entities.
  #   result = command.call(attributes: { 'author' => 'Tamsyn Muir' })
  #   result.success?
  #   #=> false
  #   result.error
  #   #=> an instance of Cuprum::Collections::NotUnique
  #
  #   # With an attributes Hash that does not match any entities.
  #   result = command.call(
  #     attributes: {
  #       'author' => 'Becky Chambers',
  #       'series' => 'The Locked Tomb'
  #     }
  #   )
  #   result.success?
  #   #=> false
  #   result.error
  #   #=> an instance of Cuprum::Collections::NotFound
  #
  # @example Finding An Entity By Query
  #   command =
  #     Cuprum::Collections::Commands::FindOneMatching
  #     .new(collection: collection)
  #
  #   # With a query that matches one entity.
  #   result = command.call do
  #     {
  #       'series'       => 'The Lord of the Rings',
  #       'published_at' => greater_than('1955-01-01')
  #     }
  #   end
  #   result.success?
  #   #=> true
  #   result.value
  #   #=> a Book matching the query
  #
  #   # With a query that matches multiple entities.
  #   result = command.call do
  #     {
  #       'series'       => 'The Lord of the Rings',
  #       'published_at' => less_than('1955-01-01')
  #     }
  #   end
  #   result.success?
  #   #=> false
  #   result.error
  #   #=> an instance of Cuprum::Collections::NotUnique
  #
  #   # With an attributes Hash that does not match any entities.
  #   result = command.call do
  #     {
  #       'series'       => 'The Lord of the Rings',
  #       'published_at' => less_than('1954-01-01')
  #     }
  #   end
  #   result.success?
  #   #=> false
  #   result.error
  #   #=> an instance of Cuprum::Collections::NotFound
  class FindOneMatching < Cuprum::Command
    # @param collection [#find_matching] The collection to query.
    def initialize(collection:)
      super()

      @collection = collection
    end

    # @return [#find_matching] the collection to query.
    attr_reader :collection

    private

    def error_params_for(attributes: nil, &block)
      { collection_name: collection.name }.merge(
        if block_given?
          { query: collection.query.where(&block) }
        else
          { attributes: }
        end
      )
    end

    def not_found_error(attributes: nil, &block)
      Cuprum::Collections::Errors::NotFound.new(
        **error_params_for(attributes:, &block)
      )
    end

    def not_unique_error(attributes: nil, &block)
      Cuprum::Collections::Errors::NotUnique.new(
        **error_params_for(attributes:, &block)
      )
    end

    def process(attributes: nil, &block)
      query    = block || -> { attributes }
      entities = step { collection.find_matching.call(limit: 2, &query) }

      require_one_entity(attributes:, entities:, &block)
    end

    def require_one_entity(attributes:, entities:, &block)
      case entities.count
      when 0
        failure(not_found_error(attributes:, &block))
      when 1
        entities.first
      when 2
        failure(not_unique_error(attributes:, &block))
      end
    end
  end
end
