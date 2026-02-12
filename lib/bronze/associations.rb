# frozen_string_literal: true

require 'bronze'

module Bronze
  # Namespace for implementing specific association types.
  module Associations
    autoload :BelongsTo, 'bronze/associations/belongs_to'
    autoload :HasMany,   'bronze/associations/has_many'
    autoload :HasOne,    'bronze/associations/has_one'
  end
end
