# frozen_string_literal: true

require 'cuprum/collections'
require 'cuprum/collections/parameters_validation'

module Cuprum::Collections
  # Abstract base class for Cuprum::Collection commands.
  class Command < Cuprum::Command
    include ParametersValidation
  end
end
