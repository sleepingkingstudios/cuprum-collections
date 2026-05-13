# frozen_string_literal: true

require 'cuprum'

require 'bronze'

# A Ruby implementation of the command pattern.
module Cuprum
  # A data abstraction layer based on the Cuprum library.
  module Collections
    include Bronze

    autoload :Adaptable,         'cuprum/collections/adaptable'
    autoload :Adapter,           'cuprum/collections/adapter'
    autoload :Adapters,          'cuprum/collections/adapters'
    autoload :Basic,             'cuprum/collections/basic'
    autoload :CollectionCommand, 'cuprum/collections/collection_command'
    autoload :Commands,          'cuprum/collections/commands'
    autoload :Repository,        'cuprum/collections/repository'

    # @return [String] the absolute path to the gem directory.
    def self.gem_path
      sep     = File::SEPARATOR
      pattern = /#{sep}lib#{sep}cuprum#{sep}?\z/

      __dir__.sub(pattern, '')
    end

    # @return [String] the current version of the gem.
    def self.version
      Bronze::VERSION
    end
  end
end
