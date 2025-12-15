# frozen_string_literal: true

require 'cuprum/collections'
require 'cuprum/collections/adaptable/command'
require 'cuprum/collections/adaptable/commands/abstract_assign_one'

require 'support/adaptable/commands'

module Spec::Support::Adaptable::Commands
  class AssignOne < Cuprum::Collections::CollectionCommand
    include Cuprum::Collections::Adaptable::Command
    include Cuprum::Collections::Adaptable::Commands::AbstractAssignOne
  end
end
