# frozen_string_literal: true

require 'cuprum/collections/relations'

module Cuprum::Collections::Relations
  # Methods for specifying a relation's primary key.
  module PrimaryKeys
    # @return [String] the name of the primary key attribute. Defaults to
    #   'id'.
    def primary_key_name
      @primary_key_name ||= options.fetch(:primary_key_name, 'id').to_s
    end

    # @return [Class, Stannum::Constraint] the type of the primary key
    #   attribute. Defaults to Integer.
    def primary_key_type
      @primary_key_type ||=
        options
          .fetch(:primary_key_type, Integer)
          .then { |obj| obj.is_a?(String) ? Object.const_get(obj) : obj }
    end
  end
end
