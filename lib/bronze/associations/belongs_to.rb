# frozen_string_literal: true

require 'bronze/association'
require 'bronze/associations'

module Bronze::Associations
  # Object representing a belongs_to association, which inverts the foreign key.
  class BelongsTo < Bronze::Association
    # (see Bronze::Association#initialize)
    def initialize(**params)
      super(**params.except(:plural), singular: true)
    end

    # (see Bronze::Association#primary_key_query?)
    def primary_key_query?
      true
    end

    private

    def default_foreign_key_name
      singular_name&.then { |str| "#{str}_id" }
    end
  end
end
