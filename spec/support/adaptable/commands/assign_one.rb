# frozen_string_literal: true

require 'bronze/adaptable/command'
require 'bronze/adaptable/commands/abstract_assign_one'
require 'bronze/commands/base'
require 'cuprum/collections'

require 'support/adaptable/commands'

module Spec::Support::Adaptable::Commands
  class AssignOne < Bronze::Commands::Base
    include Bronze::Adaptable::Command
    include Bronze::Adaptable::Commands::AbstractAssignOne
  end
end
