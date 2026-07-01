# frozen_string_literal: true

require 'cuprum'
require 'sleeping_king_studios/tools'

require 'bronze'

# A Ruby implementation of the command pattern.
module Cuprum
  # A data abstraction layer based on the Cuprum library.
  #
  # @deprecated [0.6.0] Use Bronze::Commands::Base instead.
  module Collections
    include Bronze

    SleepingKingStudios::Tools::Toolbelt
      .instance
      .core_tools
      .deprecate(
        'Cuprum::Collections',
        'Use Bronze instead'
      )

    # @return [String] the absolute path to the gem directory.
    def self.gem_path = Bronze.gem_path

    # @return [String] the current version of the gem.
    def self.version = Bronze.version
  end
end
