# frozen_string_literal: true

require 'cuprum/collections/commands'
require 'cuprum/collections/commands/create'
require 'cuprum/collections/commands/find_one_matching'
require 'cuprum/collections/commands/update'

module Cuprum::Collections::Commands
  # Command for creating or updating an entity from an attributes Hash.
  #
  # @example Creating Or Updating An Entity By Primary Key
  #   command    =
  #     Cuprum::Collections::Commands::Upsert
  #     .new(collection: books_collection)
  #
  #   # Creating A New Entity
  #   books_collection.query.count
  #   #=> 0
  #   attributes = {
  #     'id'     => 0
  #     'title'  => 'Gideon the Ninth',
  #     'author' => 'Tamsyn Muir'
  #   }
  #   result = command.call(attributes: attributes)
  #   result.value
  #   #=> a Book with id 0, title 'Gideon the Ninth', and author 'Tamsyn Muir'
  #   books_collection.query.count
  #   #=> 1
  #
  #   # Updating An Existing Entity
  #   attributes = {
  #     'id'     => 0
  #     'series' => 'The Locked Tomb'
  #   }
  #   result = command.call(attributes: attributes)
  #   result.value
  #   #=> a Book with id 0, title 'Gideon the Ninth', author 'Tamsyn Muir', and
  #       series 'The Locked Tomb'
  #   books_collection.query.count
  #   #=> 1
  #
  # @example Creating Or Updating An Entity By Attributes
  #   command    =
  #     Cuprum::Collections::Commands::Upsert
  #     .new(attribute_names: %w[title], collection: books_collection)
  #
  #   # Creating A New Entity
  #   books_collection.query.count
  #   #=> 0
  #   attributes = {
  #     'id'     => 0
  #     'title'  => 'Gideon the Ninth',
  #     'author' => 'Tamsyn Muir'
  #   }
  #   result = command.call(attributes: attributes)
  #   result.value
  #   #=> a Book with id 0, title 'Gideon the Ninth', and author 'Tamsyn Muir'
  #   books_collection.query.count
  #   #=> 1
  #
  #   # Updating An Existing Entity
  #   attributes = {
  #     'title'  => 'Gideon the Ninth',
  #     'series' => 'The Locked Tomb'
  #   }
  #   result = command.call(attributes: attributes)
  #   result.value
  #   #=> a Book with id 0, title 'Gideon the Ninth', author 'Tamsyn Muir', and
  #       series 'The Locked Tomb'
  #   books_collection.query.count
  #   #=> 1
  class Upsert < Cuprum::Command
    # @param attribute_names [String, Symbol, Array<String, Symbol>] The names
    #   of the attributes used to find the unique entity.
    # @param collection [Object] The collection used to store the entity.
    # @param contract [Stannum::Constraint] The constraint used to validate the
    #   entity. If not given, defaults to the default contract for the
    #   collection.
    def initialize(collection:, attribute_names: 'id', contract: nil)
      super()

      @attribute_names = normalize_attribute_names(attribute_names)
      @collection      = collection
      @contract        = contract
    end

    # @return [Array<String>] the names of the attributes used to find the
    #   unique entity.
    attr_reader :attribute_names

    # @return [Object] the collection used to store the entity.
    attr_reader :collection

    # @return [Stannum::Constraint] the constraint used to validate the entity.
    attr_reader :contract

    private

    def create_entity(attributes:)
      Cuprum::Collections::Commands::Create
        .new(collection:, contract:)
        .call(attributes:)
    end

    def filter_attributes(attributes:)
      tools
        .hash_tools
        .convert_keys_to_strings(attributes)
        .slice(*attribute_names)
    end

    def find_entity(attributes:)
      filtered = filter_attributes(attributes:)
      result   =
        Cuprum::Collections::Commands::FindOneMatching
          .new(collection:)
          .call(attributes: filtered)

      return if result.error.is_a?(Cuprum::Collections::Errors::NotFound)

      result
    end

    def normalize_attribute_names(attribute_names)
      names = Array(attribute_names)

      raise ArgumentError, "attribute names can't be blank" if names.empty?

      names = names.map do |name|
        unless name.is_a?(String) || name.is_a?(Symbol)
          raise ArgumentError, "invalid attribute name #{name.inspect}"
        end

        name.to_s
      end

      Set.new(names)
    end

    def process(attributes:)
      entity = step { find_entity(attributes:) }

      if entity
        update_entity(attributes:, entity:)
      else
        create_entity(attributes:)
      end
    end

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
    end

    def update_entity(attributes:, entity:)
      Cuprum::Collections::Commands::Update
        .new(collection:, contract:)
        .call(attributes:, entity:)
    end
  end
end
