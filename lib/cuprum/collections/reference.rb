# frozen_string_literal: true

require 'cuprum/collections'

module Cuprum::Collections
  # The Reference collection is an example, in-memory collection implementation.
  module Reference
    autoload :Query, 'cuprum/collections/reference/query'
  end
end
