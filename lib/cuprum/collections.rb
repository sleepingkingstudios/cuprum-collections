# frozen_string_literal: true

require 'cuprum'

# A Ruby implementation of the command pattern.
module Cuprum
  # A data abstraction layer based on the Cuprum library.
  module Collections
    autoload :Base,    'cuprum/collections/base'
    autoload :Command, 'cuprum/collections/command'

    # @return [String] the absolute path to the gem directory.
    def self.gem_path
      sep     = File::SEPARATOR
      pattern = /#{sep}lib#{sep}cuprum#{sep}?\z/

      __dir__.sub(pattern, '')
    end

    # @return [String] The current version of the gem.
    def self.version
      VERSION
    end
  end
end
