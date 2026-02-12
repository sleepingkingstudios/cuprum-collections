# frozen_string_literal: true

require 'cuprum'

# A data abstraction layer based on the Cuprum library.
module Bronze
  autoload :Association,  'bronze/association'
  autoload :Associations, 'bronze/associations'
  autoload :Errors,       'bronze/errors'
  autoload :Relation,     'bronze/relation'
  autoload :Relations,    'bronze/relations'

  # @return [String] the absolute path to the gem directory.
  def self.gem_path
    sep     = File::SEPARATOR
    pattern = /#{sep}lib#{sep}?\z/

    __dir__.sub(pattern, '')
  end

  # @return [String] the current version of the gem.
  def self.version
    VERSION
  end
end
