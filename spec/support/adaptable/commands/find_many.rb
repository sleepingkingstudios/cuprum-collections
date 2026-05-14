# frozen_string_literal: true

require 'bronze/commands/abstract_find_many'
require 'bronze/commands/base'
require 'cuprum/collections'

require 'support/adaptable/commands'

module Spec::Support::Adaptable::Commands
  class FindMany < Bronze::Commands::Base
    include Bronze::Commands::AbstractFindMany
    include Cuprum::Collections::Adaptable::Command
  end
end
