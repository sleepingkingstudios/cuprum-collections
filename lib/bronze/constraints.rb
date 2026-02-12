# frozen_string_literal: true

require 'bronze'

module Bronze
  # Namespace for Stannum constraints, which are used for parameter validation.
  module Constraints
    autoload :AttributeName, 'bronze/constraints/attribute_name'
    autoload :Order,         'bronze/constraints/order'
    autoload :Ordering,      'bronze/constraints/ordering'
    autoload :QueryHash,     'bronze/constraints/query_hash'
  end
end
