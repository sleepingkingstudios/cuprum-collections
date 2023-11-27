# frozen_string_literal: true

require 'cuprum/collections/association'
require 'cuprum/collections/associations'

module Cuprum::Collections::Associations
  # Object representing a has_many association.
  class HasMany < Cuprum::Collections::Association
    # (see Cuprum::Collections::Association#initialize)
    def initialize(**params)
      params.delete(:plural)
      params.delete(:singular)

      super(**params, singular: false)
    end

    private

    def ignored_parameters
      @ignored_parameters ||= Set.new(IGNORED_PARAMETERS + %i[singular])
    end
  end
end
