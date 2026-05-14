# frozen_string_literal: true

require 'bronze'
require 'bronze/commands/base'

module Bronze
  # @deprecated [0.6.0] Use Bronze::Commands::Base instead.
  class CollectionCommand < Bronze::Commands::Base
    class << self
      private

      def inherited(other)
        super

        SleepingKingStudios::Tools::Toolbelt
          .instance
          .core_tools
          .deprecate(
            'Bronze::CollectionCommand',
            'Use Bronze::Commands::Base instead.'
          )
      end
    end
  end
end
