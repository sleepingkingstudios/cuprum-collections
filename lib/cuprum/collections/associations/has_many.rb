# frozen_string_literal: true

require 'cuprum/collections/association'
require 'cuprum/collections/associations'

module Cuprum::Collections::Associations
  # Object representing a has_many association.
  class HasMany < Cuprum::Collections::Association
    # (see Cuprum::Collections::Association#initialize)
    def initialize(**params)
      super(**params.except(:plural), singular: false)
    end
  end
end
