# frozen_string_literal: true

require 'cuprum/collections'

module Cuprum::Collections
  # Methods for determining a collection's name and entity class from options.
  #
  # @private
  module Naming
    private

    def resolve_collection_name(collection_name: nil, entity_class: nil)
      if collection_name
        tools.assertions.validate_name(collection_name, as: 'collection name')

        return collection_name.to_s
      end

      return split_entity_class(entity_class: entity_class).last if entity_class

      tools.assertions.validate_name(collection_name, as: 'collection name')
    end

    def resolve_member_name(collection_name: nil, **options)
      if options.key?(:member_name)
        tools.assertions.validate_name(options[:member_name], as: 'member name')

        return options[:member_name].to_s
      end

      tools.string_tools.singularize(collection_name.to_s)
    end

    def resolve_qualified_name( # rubocop:disable Metrics/MethodLength
      collection_name: nil,
      entity_class:    nil,
      **options
    )
      if options.key?(:qualified_name)
        tools.assertions.validate_name(
          options[:qualified_name],
          as: 'qualified name'
        )

        return options[:qualified_name].to_s
      end

      if entity_class
        return split_entity_class(entity_class: entity_class).join('/')
      end

      collection_name.to_s
    end

    def split_entity_class(entity_class:)  # rubocop:disable Metrics/MethodLength
      entity_class_name =
        if entity_class.is_a?(Class)
          entity_class.name
        else
          tools.assertions.validate_name(entity_class, as: 'entity class')

          entity_class
        end

      entity_class_name
        .split('::')
        .map { |str| tools.string_tools.underscore(str) }
        .then { |ary| [*ary[0...-1], tools.string_tools.pluralize(ary[-1])] }
    end

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
    end
  end
end
