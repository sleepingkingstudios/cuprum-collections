# frozen_string_literal: true

require 'cuprum/collections/association'
require 'cuprum/collections/associations'

module Cuprum::Collections::Associations
  # Object representing a has_one association.
  class HasOne < Cuprum::Collections::Association
    # (see Cuprum::Collections::Association#initialize)
    def initialize(**params)
      super(**params.except(:plural), singular: true)
    end
  end
end
