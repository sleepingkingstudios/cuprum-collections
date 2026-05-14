# frozen_string_literal: true

require 'bronze/commands/abstract_find_matching'
require 'bronze/commands/base'
require 'cuprum/collections'

require 'support/adaptable/commands'

module Spec::Support::Adaptable::Commands
  class FindMatching < Bronze::Commands::Base
    include Bronze::Commands::AbstractFindMatching
    include Cuprum::Collections::Adaptable::Command
  end
end
