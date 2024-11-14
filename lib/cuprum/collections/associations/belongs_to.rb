# frozen_string_literal: true

require 'cuprum/collections/association'
require 'cuprum/collections/associations'

module Cuprum::Collections::Associations
  # Object representing a belongs_to association, which inverts the foreign key.
  class BelongsTo < Cuprum::Collections::Association
    # (see Cuprum::Collections::Association#initialize)
    def initialize(**params)
      super(**params.except(:plural), singular: true)
    end

    # (see Cuprum::Collections::Association#primary_key_query?)
    def primary_key_query?
      true
    end

    private

    def default_foreign_key_name
      singular_name&.then { |str| "#{str}_id" }
    end
  end
end
