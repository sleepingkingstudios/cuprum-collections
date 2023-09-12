# frozen_string_literal: true

require 'cuprum/collections'

module Cuprum::Collections
  # Namespace for implementing specific association types.
  module Associations
    autoload :BelongsTo, 'cuprum/collections/associations/belongs_to'
  end
end
