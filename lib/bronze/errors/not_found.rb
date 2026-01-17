# frozen_string_literal: true

require 'bronze/errors'
require 'bronze/errors/abstract_find_error'

module Bronze::Errors
  # Returned when a find command does not find the requested items.
  class NotFound < Bronze::Errors::AbstractFindError
    # Short string used to identify the type of error.
    TYPE = 'bronze.errors.not_found'

    private

    def message_fragment
      'not found'
    end
  end
end
