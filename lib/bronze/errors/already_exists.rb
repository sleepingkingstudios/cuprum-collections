# frozen_string_literal: true

require 'bronze/errors'
require 'bronze/errors/abstract_find_error'

module Bronze::Errors
  # Returned when an insert command is called with an existing record.
  class AlreadyExists < Bronze::Errors::AbstractFindError
    # Short string used to identify the type of error.
    TYPE = 'bronze.errors.already_exists'

    private

    def message_fragment
      'already exists'
    end
  end
end
