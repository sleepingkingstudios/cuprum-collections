# frozen_string_literal: true

require 'bronze'

require 'support/adaptable/commands'

module Spec::Support::Adaptable::Commands
  class FindMany < Bronze::Commands::Base
    include Bronze::Adaptable::Command
    include Bronze::Commands::AbstractFindMany
  end
end
