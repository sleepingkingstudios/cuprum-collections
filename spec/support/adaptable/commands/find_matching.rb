# frozen_string_literal: true

require 'bronze'

require 'support/adaptable/commands'

module Spec::Support::Adaptable::Commands
  class FindMatching < Bronze::Commands::Base
    include Bronze::Adaptable::Command
    include Bronze::Commands::AbstractFindMatching
  end
end
