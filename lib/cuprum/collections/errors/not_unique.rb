# frozen_string_literal: true

require 'cuprum/collections/errors'
require 'cuprum/collections/errors/abstract_find_error'

module Cuprum::Collections::Errors
  # Returned when a unique find command does finds multiple items.
  class NotUnique < Cuprum::Collections::Errors::AbstractFindError
    # Short string used to identify the type of error.
    TYPE = 'cuprum.collections.errors.not_unique'

    private

    def message_fragment
      'not unique'
    end
  end
end
