# frozen_string_literal: true

require 'cuprum/collections'

module Cuprum::Collections
  # Namespace for RSpec contracts, which validate collection implementations.
  module RSpec
    autoload :Contracts, 'cuprum/collections/rspec/contracts'
  end
end
