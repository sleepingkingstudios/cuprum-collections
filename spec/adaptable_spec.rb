# frozen_string_literal: true

require 'cuprum/collections'
require 'cuprum/collections/commands/abstract_find_matching'
require 'stannum'

################################################################################
### Abstract Implementations
################################################################################

class Adapter
  def build(data:) = raise 'Not implemented'

  def merge(data:, entity:) = raise 'Not implemented'

  def serialize(entity:) = raise 'Not implemented'

  def validate(entity:, as: 'entity') = raise 'Not implemented'

  private

  def tools
    SleepingKingStudios::Tools::Toolbelt.instance
  end
end

module Adaptable
  class Command < Cuprum::Collections::CollectionCommand
    def adapter
      collection.adapter
    end

    private

    def validate_entity(entity, as: 'entity')
      adapter.validate(entity:, as:)
    end
  end

  module Commands
    class AssignOne < Adaptable::Command
      validate :attributes
      validate :entity

      private

      def process(attributes:, entity:)
        data = tools.hsh.convert_keys_to_strings(attributes)

        adapter.merge(data:, entity:)
      end
    end

    class BuildOne < Adaptable::Command
      validate :attributes

      private

      def process(attributes:)
        data = tools.hsh.convert_keys_to_strings(attributes)

        adapter.build(data:)
      end
    end

    class DestroyOne < Adaptable::Command; end

    class FindMany < Adaptable::Command; end

    class FindMatching < Adaptable::Command
      include Cuprum::Collections::Commands::AbstractFindMatching

      validate :envelope, :boolean, optional: true
      validate :limit,    Integer,  optional: true
      validate :offset,   Integer,  optional: true
      validate :order
      validate :where
    end

    class FindOne < Adaptable::Command; end

    class InsertOne < Adaptable::Command
      validate :entity
    end
  end

  class Collection < Cuprum::Collections::Collection
    def initialize(adapter:, entity_class: nil, **rest)
      entity_class ||= adapter.entity_class

      super(entity_class:, **rest)

      @adapter = adapter
    end

    attr_reader :adapter

    command :assign_one do
      Adaptable::Commands::AssignOne.new(collection: self)
    end

    command :build_one do
      Adaptable::Commands::BuildOne.new(collection: self)
    end

    command :find_matching do
      Adaptable::Commands::FindMatching.new(collection: self)
    end
  end

  class Query < Cuprum::Collections::Query
    def initialize(adapter:, scope: nil)
      super(scope:)

      @adapter = adapter
    end

    attr_reader :adapter
  end
end

################################################################################
### Concrete Implementations
################################################################################

class EntityAdapter
  def initialize(entity_class:)
    @entity_class = entity_class
  end

  attr_reader :entity_class

  def build(data:)
    entity_class.new(**generate_primary_key, **data)
  end

  def merge(data:, entity:)
    entity.assign_attributes(**data)

    entity
  end

  def serialize(entity:) = entity.attributes

  def validate(entity:, as: 'entity')
    return if entity.is_a?(entity_class)

    tools.assertions.error_message_for(
      'sleeping_king_studios.tools.toolbelt.instance_of',
      as:,
      expected: entity_class
    )
  end

  private

  def generate_primary_key
    { id: SecureRandom.uuid_v7 }
  end
end

module Memory
  module Commands
    class InsertOne < Adaptable::Commands::InsertOne
      private

      def find_existing(entity:)
        value = entity[primary_key_name.to_s]
        index =
          collection.data.index { |item| item[primary_key_name.to_s] == value }

        return if index.nil?

        error = Cuprum::Collections::Errors::AlreadyExists.new(
          attribute_name:  primary_key_name,
          attribute_value: value,
          collection_name:,
          primary_key:     true
        )
        failure(error)
      end

      def process(entity:)
        entity = adapter.serialize(entity:)

        step { find_existing(entity:) }

        collection.data << tools.hash_tools.deep_dup(entity)

        entity
      end
    end
  end

  class Collection < Adaptable::Collection
    def initialize(adapter:, data: [], **rest)
      super(adapter:, **rest)

      @data = data
    end

    attr_reader :data

    command :insert_one do
      Memory::Commands::InsertOne.new(collection: self)
    end

    # @return [Stannum::Constraints::Base, nil] the #   default contract for
    #   validating items in the collection.
    def default_contract
      @options[:default_contract]
    end

    # A new Query instance, used for querying against the collection data.
    #
    # @return [Cuprum::Collections::Basic::Query] the query.
    def query
      Memory::Query.new(adapter:, data:, scope:)
    end
  end

  class Query < Adaptable::Query
    def initialize(adapter:, data:, scope: nil)
      super(adapter:, scope:)

      @data = data
    end

    def each(...)
      return enum_for(:each, ...) unless block_given?

      mapped_data.each(...)
    end

    def exists?
      return data.any? unless scope

      data.any? { |item| scope.match?(item:) }
    end

    def to_a
      mapped_data
    end

    protected

    def reset!
      @mapped_data = nil

      self
    end

    private

    attr_reader :data

    def apply_limit_offset(data)
      return data[@offset...(@offset + @limit)] || [] if @limit && @offset
      return data[0...@limit] if @limit

      return data[@offset..] || [] if @offset

      data
    end

    def apply_order(data)
      return data if @order.empty?

      data.sort do |u, v|
        @order.reduce(0) do |memo, (attribute, direction)|
          next memo unless memo.zero?

          attr_name = attribute.to_s

          cmp = u[attr_name] <=> v[attr_name]

          direction == :asc ? cmp : -cmp
        end
      end
    end

    def apply_scope(data)
      scope ? scope.call(data:) : data
    end

    def default_scope
      Cuprum::Collections::Basic::Scopes::AllScope.instance
    end

    def mapped_data
      @mapped_data ||= scoped_data.map { |data| adapter.build(data:) }
    end

    def scoped_data
      data
        .then { |ary| apply_scope(ary) }
        .then { |ary| apply_order(ary) }
        .then { |ary| apply_limit_offset(ary) }
    end
  end
end

################################################################################
### Test Fixtures
################################################################################

class Book
  include Stannum::Entity

  define_primary_key :id, Stannum::Constraints::Uuid

  define_attribute :author, String
  define_attribute :series, String
  define_attribute :title,  String
end

define_method :tools do
  SleepingKingStudios::Tools::Toolbelt.instance
end

data = ['Gideon the Ninth', 'Harrow the Ninth', 'Nona the Ninth']
  .map { |title| { title:, author: 'Tamsyn Muir', series: 'The Locked Tomb' } }
  .map { |attributes| { id: SecureRandom.uuid_v7 }.merge(attributes) }
  .map { |attributes| tools.hash_tools.convert_keys_to_strings(attributes) }
adapter    = EntityAdapter.new(entity_class: Book)
collection = Memory::Collection.new(adapter:, data:)
attributes = { title: 'Alecto the Ninth', author: 'Tamsyn Muir' }
entity     = collection.build_one.call(attributes:).value
attributes = { series: 'The Locked Tomb' }
entity     = collection.assign_one.call(attributes:, entity:).value

collection.insert_one.call(entity:)

byebug
self
