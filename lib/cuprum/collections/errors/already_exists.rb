# frozen_string_literal: true

require 'cuprum/collections/errors'
require 'cuprum/collections/errors/abstract_find_error'

module Cuprum::Collections::Errors
  # Returned when an insert command is called with an existing record.
  class AlreadyExists < Cuprum::Collections::Errors::AbstractFindError
    # Short string used to identify the type of error.
    TYPE = 'cuprum.collections.errors.already_exists'

    private

    def message_fragment
      'already exists'
    end
  end
end
