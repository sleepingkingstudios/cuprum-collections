# frozen_string_literal: true

require 'bronze/commands/abstract_find_one'
require 'bronze/commands/base'
require 'cuprum/collections'

require 'support/adaptable/commands'

module Spec::Support::Adaptable::Commands
  class FindOne < Bronze::Commands::Base
    include Bronze::Commands::AbstractFindOne
    include Cuprum::Collections::Adaptable::Command
  end
end
