# frozen_string_literal: true

require 'cuprum/collections'

module Cuprum::Collections
  # Namespace for RSpec contracts, which validate collection implementations.
  module RSpec
    autoload :Fixtures, 'cuprum/collections/rspec/fixtures'
  end
end
