# frozen_string_literal: true

require 'bronze/errors'
require 'bronze/errors/abstract_find_error'

module Bronze::Errors
  # Returned when a unique find command does finds multiple items.
  class NotUnique < Bronze::Errors::AbstractFindError
    # Short string used to identify the type of error.
    TYPE = 'bronze.errors.not_unique'

    private

    def message_fragment
      'not unique'
    end
  end
end
