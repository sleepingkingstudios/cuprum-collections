# frozen_string_literal: true

require 'cuprum/collections'
require 'cuprum/collections/commands/abstract_find_one'

require 'support/adaptable/commands'

module Spec::Support::Adaptable::Commands
  class FindOne < Cuprum::Collections::CollectionCommand
    include Cuprum::Collections::Adaptable::Command
    include Cuprum::Collections::Commands::AbstractFindOne
  end
end
