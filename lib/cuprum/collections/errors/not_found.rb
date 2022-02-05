# frozen_string_literal: true

require 'cuprum/collections/errors'
require 'cuprum/collections/errors/abstract_find_error'

module Cuprum::Collections::Errors
  # Returned when a find command does not find the requested items.
  class NotFound < Cuprum::Collections::Errors::AbstractFindError
    # Short string used to identify the type of error.
    TYPE = 'cuprum.collections.errors.not_found'

    private

    def message_fragment
      'not found'
    end
  end
end
