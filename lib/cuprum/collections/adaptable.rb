# frozen_string_literal: true

require 'cuprum/collections'

module Cuprum::Collections
  # Namespace for defining adaptable collections.
  module Adaptable
    autoload :Query, 'cuprum/collections/adaptable/query'
  end
end
