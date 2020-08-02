# frozen_string_literal: true

require 'cuprum'

module Cuprum
  # A data abstraction layer based on the Cuprum library.
  module Collections
    # @return [String] The current version of the gem.
    def version
      VERSION
    end
  end
end
