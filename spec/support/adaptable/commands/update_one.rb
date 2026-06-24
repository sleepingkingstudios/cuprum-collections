# frozen_string_literal: true

require 'bronze/adaptable/command'
require 'cuprum/collections'

require 'support/adaptable/commands'

module Spec::Support::Adaptable::Commands
  class UpdateOne < Cuprum::Collections::Basic::Commands::UpdateOne
    include Bronze::Adaptable::Command

    private

    def process(entity:)
      attributes = step { adapter.serialize(entity:) }
      attributes = step { super(entity: attributes) }

      adapter.build(attributes:)
    end
  end
end
