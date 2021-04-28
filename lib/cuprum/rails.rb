# frozen_string_literal: true

require 'cuprum'

module Cuprum
  # The Rails collection wraps an ActiveRecord model as a Cuprum collection.
  module Rails
    autoload :Collection, 'cuprum/rails/collection'
    autoload :Command,    'cuprum/rails/command'
    autoload :Query,      'cuprum/rails/query'
  end
end
