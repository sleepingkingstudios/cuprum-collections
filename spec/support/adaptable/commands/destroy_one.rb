# frozen_string_literal: true

require 'cuprum/collections'
require 'cuprum/collections/adaptable/command'

require 'support/adaptable/commands'

module Spec::Support::Adaptable::Commands
  class DestroyOne < Cuprum::Collections::Basic::Commands::DestroyOne
    include Cuprum::Collections::Adaptable::Command

    private

    def process(primary_key:)
      attributes = step { super }

      adapter.build(attributes:)
    end
  end
end
