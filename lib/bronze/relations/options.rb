# frozen_string_literal: true

require 'bronze/relations'

module Bronze::Relations
  # Methods for storing arbitrary options for a relation.
  module Options
    # @param options [Hash] additional options for the relation.
    def initialize(**options)
      super()

      @options = options
    end

    # @return [Hash] additional options for the relation.
    attr_reader :options
  end
end
