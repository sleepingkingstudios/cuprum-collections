# frozen_string_literal: true

require 'cuprum/collections'
require 'cuprum/collections/adaptable/command'

require 'support/adaptable/commands'

module Spec::Support::Adaptable::Commands
  class UpdateOne < Cuprum::Collections::Basic::Commands::UpdateOne
    include Cuprum::Collections::Adaptable::Command

    private

    def process(entity:)
      attributes = step { adapter.serialize(entity:) }
      attributes = step { super(entity: attributes) }

      adapter.build(attributes:)
    end
  end
end
