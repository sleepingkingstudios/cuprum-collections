# frozen_string_literal: true

require 'cuprum/collections/adaptable'

module Cuprum::Collections::Adaptable
  # Namespace for adaptable command implementations.
  module Commands
    autoload :AbstractAssignOne,
      'cuprum/collections/adaptable/commands/abstract_assign_one'
    autoload :AbstractBuildOne,
      'cuprum/collections/adaptable/commands/abstract_build_one'
    autoload :AbstractValidateOne,
      'cuprum/collections/adaptable/commands/abstract_validate_one'
  end
end
