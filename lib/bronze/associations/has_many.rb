# frozen_string_literal: true

require 'bronze/association'
require 'bronze/associations'

module Bronze::Associations
  # Object representing a has_many association.
  class HasMany < Bronze::Association
    # (see Bronze::Association#initialize)
    def initialize(**params)
      super(**params.except(:plural), singular: false)
    end
  end
end
