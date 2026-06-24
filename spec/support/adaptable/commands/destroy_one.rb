# frozen_string_literal: true

require 'bronze/adaptable/command'
require 'cuprum/collections'

require 'support/adaptable/commands'

module Spec::Support::Adaptable::Commands
  class DestroyOne < Cuprum::Collections::Basic::Commands::DestroyOne
    include Bronze::Adaptable::Command

    private

    def process(primary_key:)
      attributes = step { super }

      adapter.build(attributes:)
    end
  end
end
