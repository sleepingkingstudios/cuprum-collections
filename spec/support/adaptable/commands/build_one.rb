# frozen_string_literal: true

require 'bronze'

require 'support/adaptable/commands'

module Spec::Support::Adaptable::Commands
  class BuildOne < Bronze::Commands::Base
    include Bronze::Adaptable::Command
    include Bronze::Adaptable::Commands::AbstractBuildOne
  end
end
