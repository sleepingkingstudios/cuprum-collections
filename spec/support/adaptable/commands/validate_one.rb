# frozen_string_literal: true

require 'bronze/adaptable/command'
require 'bronze/adaptable/commands/abstract_validate_one'
require 'bronze/commands/base'
require 'cuprum/collections'

require 'support/adaptable/commands'

module Spec::Support::Adaptable::Commands
  class ValidateOne < Bronze::Commands::Base
    include Bronze::Adaptable::Command
    include Bronze::Adaptable::Commands::AbstractValidateOne
  end
end
