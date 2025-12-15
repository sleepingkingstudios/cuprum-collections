# frozen_string_literal: true

require 'cuprum/collections'
require 'cuprum/collections/commands/abstract_find_matching'

require 'support/adaptable/commands'

module Spec::Support::Adaptable::Commands
  class FindMatching < Cuprum::Collections::CollectionCommand
    include Cuprum::Collections::Adaptable::Command
    include Cuprum::Collections::Commands::AbstractFindMatching
  end
end
