# frozen_string_literal: true

require 'bronze'

module Bronze
  # Namespace for defining adaptable collections.
  module Adaptable
    autoload :Collection, 'bronze/adaptable/collection'
    autoload :Command,    'bronze/adaptable/command'
    autoload :Commands,   'bronze/adaptable/commands'
    autoload :Query,      'bronze/adaptable/query'
  end
end
