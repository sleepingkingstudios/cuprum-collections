# frozen_string_literal: true

require 'cuprum/collections'
require 'cuprum/collections/commands/abstract_find_many'

require 'support/adaptable/commands'

module Spec::Support::Adaptable::Commands
  class FindMany < Cuprum::Collections::CollectionCommand
    include Cuprum::Collections::Adaptable::Command
    include Cuprum::Collections::Commands::AbstractFindMany
  end
end
