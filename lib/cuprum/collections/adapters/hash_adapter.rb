# frozen_string_literal: true

require 'cuprum/collections/adapter'
require 'cuprum/collections/adapters'

module Cuprum::Collections::Adapters
  # Utility class for converting between raw attributes and a data Hash.
  class HashAdapter < Cuprum::Collections::Adapter
    # @param options [Hash] options for initializing the adapter.
    #
    # @option options allow_extra_attributes [true, false] if false, attributes
    #   methods return an error for attributes not in attributes_names. Defaults
    #   to true if attribute_names is empty, otherwise false.
    # @option options attributes_names [Array<String, Symbol>] the valid
    #   attribute names for a data object. Defaults to [].
    # @option options default_contract [Stannum::Constraints:Base] the contract
    #   used to validate instances of the data object.
    def initialize(**options)
      if options[:entity_class]
        raise ArgumentError, 'adapter does not support entity class'
      end

      super(entity_class: Hash, **options)
    end

    private

    def build_entity(attributes:)
      attributes = tools.hash_tools.convert_keys_to_strings(attributes)

      empty_attributes.merge(attributes)
    end

    def empty_attributes
      @empty_attributes ||= attribute_names.to_h { |key| [key, nil] }
    end

    def merge_entity(attributes:, entity:)
      attributes = tools.hash_tools.convert_keys_to_strings(attributes)

      entity.merge(attributes)
    end

    def serialize_entity(entity:)
      entity.dup
    end
  end
end
