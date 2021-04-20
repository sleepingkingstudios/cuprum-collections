# frozen_string_literal: true

require 'cuprum/collections'

module Cuprum::Collections
  # The Basic collection is an example, in-memory collection implementation.
  module Basic
    autoload :Command, 'cuprum/collections/basic/command'
    autoload :Query,   'cuprum/collections/basic/query'
  end
end
