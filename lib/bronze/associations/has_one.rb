# frozen_string_literal: true

require 'bronze/association'
require 'bronze/associations'

module Bronze::Associations
  # Object representing a has_one association.
  class HasOne < Bronze::Association
    # (see Bronze::Association#initialize)
    def initialize(**params)
      super(**params.except(:plural), singular: true)
    end
  end
end
