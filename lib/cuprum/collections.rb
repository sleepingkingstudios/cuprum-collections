# frozen_string_literal: true

require 'cuprum'

# A Ruby implementation of the command pattern.
module Cuprum
  # A data abstraction layer based on the Cuprum library.
  module Collections
    autoload :Basic,      'cuprum/collections/basic'
    autoload :Collection, 'cuprum/collections/collection'
    autoload :Command,    'cuprum/collections/command'
    autoload :Errors,     'cuprum/collections/errors'
    autoload :Repository, 'cuprum/collections/repository'

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
