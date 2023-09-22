# frozen_string_literal: true

require 'cuprum/collections/association'
require 'cuprum/collections/associations'

module Cuprum::Collections::Associations
  # Object representing a belongs_to association, which inverts the foreign key.
  class BelongsTo < Cuprum::Collections::Association
    # (see Cuprum::Collections::Association#initialize)
    def initialize(**params)
      params.delete(:plural)
      params.delete(:singular)

      super(**params, singular: true)
    end

    # (see Cuprum::Collections::Association#primary_key_query?)
    def primary_key_query?
      true
    end

    private

    def default_foreign_key_name
      singular_name&.then { |str| "#{str}_id" }
    end

    def ignored_parameters
      @ignored_parameters ||= Set.new(IGNORED_PARAMETERS + %i[singular])
    end
  end
end
