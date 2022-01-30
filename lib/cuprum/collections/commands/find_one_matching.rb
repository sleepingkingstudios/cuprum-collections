# frozen_string_literal: true

require 'cuprum/collections/commands'
require 'cuprum/collections/errors/not_found'
require 'cuprum/collections/errors/not_unique'

module Cuprum::Collections::Commands
  # Command for finding a unique entity by a query or set of attributes.
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
      { collection_name: collection.collection_name }.merge(
        if block_given?
          { query: collection.query.where(&block) }
        else
          { attributes: attributes }
        end
      )
    end

    def not_found_error(attributes: nil, &block)
      Cuprum::Collections::Errors::NotFound.new(
        **error_params_for(attributes: attributes, &block)
      )
    end

    def not_unique_error(attributes: nil, &block)
      Cuprum::Collections::Errors::NotUnique.new(
        **error_params_for(attributes: attributes, &block)
      )
    end

    def process(attributes: nil, &block)
      query    = block || -> { attributes }
      entities = step { collection.find_matching.call(limit: 2, &query) }

      require_one_entity(attributes: attributes, entities: entities, &block)
    end

    def require_one_entity(attributes:, entities:, &block)
      case entities.count
      when 0
        failure(not_found_error(attributes: attributes, &block))
      when 1
        entities.first
      when 2
        failure(not_unique_error(attributes: attributes, &block))
      end
    end
  end
end
