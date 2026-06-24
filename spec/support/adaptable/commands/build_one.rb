# frozen_string_literal: true

require 'bronze/adaptable/command'
require 'bronze/adaptable/commands/abstract_build_one'
require 'bronze/commands/base'
require 'cuprum/collections'

require 'support/adaptable/commands'

module Spec::Support::Adaptable::Commands
  class BuildOne < Bronze::Commands::Base
    include Bronze::Adaptable::Command
    include Bronze::Adaptable::Commands::AbstractBuildOne
  end
end
