# frozen_string_literal: true

require 'cuprum/collections/errors/abstract_find_error'
require 'cuprum/collections/errors/associations'

module Cuprum::Collections::Errors::Associations
  # Returned when an association command does not find the requested items.
  class NotFound < Cuprum::Collections::Errors::AbstractFindError
    # Short string used to identify the type of error.
    TYPE = 'cuprum.collections.errors.associations.not_found'

    private

    def message_fragment
      'not found'
    end
  end
end
