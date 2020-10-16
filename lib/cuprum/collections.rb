# frozen_string_literal: true

require 'cuprum'

# A Ruby implementation of the command pattern.
module Cuprum
  # A data abstraction layer based on the Cuprum library.
  module Collections
    autoload :Base, 'cuprum/collections/base'

    # @return [String] The current version of the gem.
    def self.version
      VERSION
    end
  end
end
