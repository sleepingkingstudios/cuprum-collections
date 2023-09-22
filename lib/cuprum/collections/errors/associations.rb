# frozen_string_literal: true

require 'cuprum/collections/errors'

module Cuprum::Collections::Errors
  # Namespace for errors when calling association commands.
  module Associations
    autoload :NotFound, 'cuprum/collections/errors/associations/not_found'
  end
end
